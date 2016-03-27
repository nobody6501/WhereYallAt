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
    let facebookLogin = FBSDKLoginManager()
    var uid = ""
    
    let root = Firebase(url:"https://amber-torch-9345.firebaseio.com/")
    var latitude: CLLocationDegrees!
    var longitude: CLLocationDegrees!

    override func viewDidLoad() {
        super.viewDidLoad()
//        root = Firebase(url:"https://amber-torch-9345.firebaseio.com/")
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
        
        fbFriendRequest()
        
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
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        
    }
    
}

