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
    let destinationPin = ColorPointAnnotation(pinColor: UIColor.redColor())
    
    var uid = ""
    var updateFriendsLocationTimer: NSTimer = NSTimer()
    var destination: MKMapItem = MKMapItem()
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!
    var friendLat: CLLocationDegrees!
    var friendLong: CLLocationDegrees!
    var destLong: CLLocationDegrees!
    var destLat: CLLocationDegrees!
    var isDestination: Bool = false
    var isFriendRoute: Bool = false
    var addedDestination: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fbCurrentUserID()
        fbFriendRequest()
        
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
        
        retrieveFriendsLocation()
        updateFriendsLocationTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "retrieveFriendsLocation", userInfo: nil, repeats: true)
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
    
//    func updateCurrentCoordinates() {
//        
//    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Errors: " + error.localizedDescription)
    }

    
    @IBAction func addPin(sender: UILongPressGestureRecognizer) {
        if(uiSwitch.on) {
            isDestination = true
            
            var overlays = self.mapView.overlays
            self.mapView.removeOverlays(overlays)
            
            let location = sender.locationInView(self.mapView)
            let locCord = self.mapView.convertPoint(location, toCoordinateFromView: self.mapView)
            
            destLong = locCord.longitude
            destLat = locCord.latitude
            
            
            //add to backend
            var destinationLocation : [String:CLLocationDegrees] = [
                "longitude": destLong,
                "latitude": destLat
            ]
            root.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("Destination").setValue(destinationLocation)
            
            addedDestination = true
            
            destinationPin.coordinate = locCord
            destinationPin.title = "Meet Here!"
            
            let destinationMark = MKPlacemark(coordinate: locCord, addressDictionary: nil)
            
            destination = MKMapItem(placemark: destinationMark)
            
            self.mapView.removeAnnotation(destinationPin)
            self.mapView.addAnnotation(destinationPin)
            
            showCurrentUserDirections()
            
            showFriendsToDestination(friendLat, friendLong: friendLong)
            retrieveFriendsLocation()
        }
        else {
            let alertController = UIAlertController(title: "Error", message:
                "Cannot drop pin while offline", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //drop pin for friend location
    func dropFriendsPin (lat: CLLocationDegrees, long: CLLocationDegrees) {
        let friendsCoord = CLLocationCoordinate2DMake(lat,long)
        
        let annotation = ColorPointAnnotation(pinColor: UIColor.greenColor())
        
        annotation.coordinate = friendsCoord
        annotation.title = "TEST FRIEND!"
        let placeMark = MKPlacemark(coordinate: friendsCoord, addressDictionary: nil)
        
        destination = MKMapItem(placemark: placeMark)
        self.mapView.addAnnotation(annotation)
        
    }
    
    //route for friend to destination
    func showFriendsToDestination(friendLat: CLLocationDegrees, friendLong: CLLocationDegrees) {
        let request = MKDirectionsRequest()
        var friendMark = MKPlacemark(coordinate: CLLocationCoordinate2DMake(friendLat, friendLong), addressDictionary: nil)
        let source = MKMapItem(placemark: friendMark)
    
        request.source = source
        request.destination = destination
        request.requestsAlternateRoutes = false
        
        let directions = MKDirections(request: request)
        
        directions.calculateDirectionsWithCompletionHandler{ response, error in
            guard let response = response else {
                print("Error \(error)")
                return
            }
            
            for route in response.routes as! [MKRoute] {
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            }
        }
    }
    
    func showCurrentUserDirections() {
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
            
            for route in response.routes as! [MKRoute] {
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
            }
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        let draw = MKPolylineRenderer(overlay: overlay)

        if(isFriendRoute) {
            draw.strokeColor = UIColor.lightGrayColor()
            draw.lineWidth = 3.0
            isFriendRoute = false
        } else {
            draw.strokeColor = UIColor.blueColor()
            draw.lineWidth = 3.0
        }
        return draw
    }
    
    func retrieveFriendsLocation() {
        root.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("friends").observeEventType(.ChildAdded, withBlock: { myFriendsUID in
            
            self.root.childByAppendingPath("users").observeEventType(.ChildAdded, withBlock: { snapshot in
                if (myFriendsUID.key == snapshot.key) {
                    
                    self.root.childByAppendingPath("users").childByAppendingPath(myFriendsUID.key).childByAppendingPath("locations").observeEventType(.ChildAdded, withBlock: { locationValues in
                        
                        if(locationValues.key == "latitude") {
                            self.friendLat = locationValues.value as! CLLocationDegrees
                            
                        }
                        if (locationValues.key == "longitude"){
                            self.friendLong = locationValues.value as! CLLocationDegrees

                        }
                        
                        if((self.friendLong) != nil && (self.friendLat != nil)) {
                            self.dropFriendsPin(self.friendLat, long: self.friendLong)
                            self.showFriendsToDestination(self.friendLat, friendLong: self.friendLong)
                        }
                    })
                }
            })
        })
    }
    
    //not done
    func shareDestination() {
        root.childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("friends").observeEventType(.ChildAdded, withBlock: { myFriendsUID in
            self.root.childByAppendingPath("users").observeEventType(.ChildAdded, withBlock: { snapshot in
                if (myFriendsUID.key == snapshot.key) {
                    self.root.childByAppendingPath("users").childByAppendingPath(myFriendsUID.key).childByAppendingPath("destination").observeEventType(.ChildAdded, withBlock: { destinationValues in
                    
                        
                    })
                }
            })
        })
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            let colorPointAnnotation = annotation as! ColorPointAnnotation
            pinView?.pinTintColor = colorPointAnnotation.pinColor
        }
        if isDestination {
            let colorPointAnnotation = annotation as! ColorPointAnnotation
            pinView?.pinTintColor = colorPointAnnotation.pinColor        }
        
        isDestination = false
        return pinView
    }

    @IBOutlet weak var uiSwitch: UISwitch!
    @IBAction func LocationSwitch(sender: UISwitch) {
        if uiSwitch.on
        {
            self.locationManager.delegate = self
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        }
        else
        {
            self.locationManager.stopUpdatingLocation()
            self.mapView.showsUserLocation = false
        }

    }
    
    @IBAction func LogoutButton(sender: AnyObject) {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let loginView = storyBoard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginView, animated:true, completion:nil)
    }
    
    
}

