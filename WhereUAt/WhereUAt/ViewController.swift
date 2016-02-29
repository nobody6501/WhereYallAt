//
//  ViewController.swift
//  WhereUAt
//
//  Created by Angel Xiao on 2/25/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, HolderViewDelegate, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var didFindMyLocation = false
    
    @IBOutlet weak var viewMap: GMSMapView!
    
    var holderView = HolderView(frame:CGRectZero)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
        
        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "transition",
            userInfo: nil, repeats: false)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        let camera: GMSCameraPosition = GMSCameraPosition.cameraWithLatitude(48.857165, longitude: 2.354613, zoom: 8.0)
        viewMap.camera = camera
        // Do any additional setup after loading the view, typically from a nib.
        //        let mapView = self.view as! GMSMapView
        viewMap.addObserver(self, forKeyPath: "myLocation", options: NSKeyValueObservingOptions.New, context: nil)
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