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
    
    var root: Firebase?
//    var geofire: GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        root = Firebase(url:"https://amber-torch-9345.firebaseio.com/")
        let userRoot = root!.childByAppendingPath("user").childByAutoId()
        
        
        //only friends using app is fetched
        var fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);
        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            if error == nil {
                
                let data = result["data"]
                for anItem in (data as! [Dictionary<String, AnyObject>]) {
                    let personName = anItem["name"] as! String
                    let personID = anItem["id"] as! String
                    // do something with personName and personID
                    print("Friends ID are: \(personID)")
                }
                print("Friends are : \(result)")
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        
        let location = locations.last
        
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
        var longitude = location!.coordinate.longitude
        var latitude = location!.coordinate.latitude
        var coordinates : [String:CLLocationDegrees] = [
            "longitude": longitude,
            "latitude": latitude
        ]
        
        let locationRoot = root!.childByAppendingPath("locations").childByAutoId()

        locationRoot.setValue(coordinates)
        
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError)
    {
        print("Errors: " + error.localizedDescription)
    }
    
    @IBAction func LogoutButton(sender: AnyObject)
    {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        
        let loginPage = self.storyboard?.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        let loginNav = UINavigationController(rootViewController: loginPage)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = loginNav
        
    }
    
    
}

