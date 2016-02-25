//
//  ViewController.swift
//  WhereUAt
//
//  Created by Angel Xiao on 2/25/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import UIKit
import GoogleMaps
class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        let mapView = self.view as! GMSMapView
        var camera = GMSCameraPosition.cameraWithLatitude(-33.86, longitude: 151.20, zoom: 10)
        var mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.myLocationEnabled = true
        self.view = mapView
        
        var marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(-33.86, 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

