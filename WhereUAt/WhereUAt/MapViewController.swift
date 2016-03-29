//
//  ViewController.swift
//  CurrentLocation
//
//  Created by Martin Huang on 3/4/16.
//  Copyright © 2016 Martin Huang. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit


class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    let root = Firebase(url:"https://amber-torch-9345.firebaseio.com/")
    let facebookLogin = FBSDKLoginManager()
    
    var uid = ""
    var destination: MKMapItem = MKMapItem()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!

    override func viewDidLoad() {
        super.viewDidLoad()
        fbCurrentUserID()
        fbFriendRequest()
        
//        getAllUsersID()
//        getFriendUID()
    }
    
    func fbCurrentUserID() {
        let userRoot = root!.childByAppendingPath("users")
        var fbRequest = FBSDKGraphRequest(graphPath:"/me/", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
                self.uid = result.valueForKey("id") as! String
                let currentUser = userRoot.childByAppendingPath(self.uid)
                currentUser.setValue(self.uid)
                
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    //only friends using app is fetched
    func fbFriendRequest() {
        var fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
                
                let data = result["data"]
                for anItem in (data as! [Dictionary<String, AnyObject>]) {
                    let personName = anItem["name"] as! String
                    let personID = anItem["id"] as! String
                    // do something with personName and personID
                    let uidRoot = self.root!.childByAppendingPath("users").childByAppendingPath(self.uid).childByAppendingPath("friends").childByAppendingPath(personID)
                    var friendsInfo : [String: String] = ["Name": personName, "ID": personID]
                    uidRoot.setValue(friendsInfo)
                }
            } else {
                print("Error Getting Friends \(error)");
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
        getFriendUID()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        longitude = location!.coordinate.longitude
        latitude = location!.coordinate.latitude
        var coordinates : [String:CLLocationDegrees] = [
            "longitude": longitude,
            "latitude": latitude
        ]
        
        let locationRoot = root!.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("locations")

        locationRoot.setValue(coordinates)
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }
    
    @IBAction func LogoutButton(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let loginNav = UINavigationController(rootViewController: loginPage)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = loginNav
    }
    
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        
        let location = sender.locationInView(self.mapView)
        
        let locCord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = locCord
        annotation.title = "Meet Here!"
        
        let placeMark = MKPlacemark(coordinate: locCord, addressDictionary: nil)
        
        destination = MKMapItem(placemark: placeMark)
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)

        showDirections()
        
    }
    
    func showDirections() {
        let request = MKDirectionsRequest()
        request.source = MKMapItem.mapItemForCurrentLocation()
        request.destination = destination
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler{ response, error in
            guard let response = response else {
                print("Error \(error)")
                return
            }
            
            var overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            
            for route in response.routes as! [MKRoute] {
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            }
            
        }
        
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let draw = MKPolylineRenderer(overlay: overlay)
        draw.strokeColor = UIColor.purpleColor()
        draw.lineWidth = 3.0
        
        return draw
    }
    
    func getAllUsersID() {
        
        let testID = "768394153262588"
        root.childByAppendingPath("users").observeEventType(.ChildAdded, withBlock: { snapshot in
            if (testID == snapshot.key) {
                
                print(snapshot.key)
            }
            
        
        })
    }
    
    func getFriendUID() {
        root.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("friends").observeEventType(.ChildAdded, withBlock: { snapshot in
            print(snapshot.key)
            print("friendIDs")
            
        })
    }
    
//    func friendsLocation () {
//        
//        let friendsCoord = CLLocationCoordinate2DMake(,)
//        // Drop a pin
//        let dropPin = MKPointAnnotation()
//        dropPin.coordinate = friendsCoord
//        dropPin.title =
//        mapView.addAnnotation(dropPin)
//    }

    
}

