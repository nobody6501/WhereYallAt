//
//  ViewController.swift
//  WhereUAt
//
//  Created by Angel Xiao on 2/25/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import UIKit
//import CoreLocation
//import GoogleMaps

class ViewController: UIViewController, HolderViewDelegate {
//    var locationManager = CLLocationManager()
//    var didFindMyLocation = false
    
    var holderView = HolderView(frame:CGRectZero)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
        
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "transition",
            userInfo: nil, repeats: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
        
        
    }
    
//    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [String : AnyObject], context: UnsafeMutablePointer<Void>) {
//        if !didFindMyLocation {
//            let myLocation: CLLocation = change[NSKeyValueChangeNewKey] as! CLLocation
//            viewMap.camera = GMSCameraPosition.cameraWithTarget(myLocation.coordinate, zoom: 10.0)
//            viewMap.settings.myLocationButton = true
//            
//            didFindMyLocation = true
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addHolderView() {
        let boxSize: CGFloat = 100.0
        holderView.frame = CGRect(x: view.bounds.width / 2 - boxSize / 2,
            y: view.bounds.height / 2 - boxSize / 2,
            width: boxSize,
            height: boxSize)
        holderView.parentFrame = view.frame
        holderView.delegate = self
        view.addSubview(holderView)
        holderView.addOval()
        
        //transition()
    }

    func backgroundLabel() {
    }
    
    func transition(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyBoard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        self.presentViewController(secondViewController, animated: true, completion: nil)
    }
}