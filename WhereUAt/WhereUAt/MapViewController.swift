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
import GeoFire

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var root: Firebase?
    var geofire: GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        root = Firebase(url:"https://amber-torch-9345.firebaseio.com/")
//        let key = locationRoot.key
        
//        var updateCurrentLocation = ["locations/\(key)":true,"\(key)":["longitude": longitude, "latitude": latitude]]
        
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
    
}

