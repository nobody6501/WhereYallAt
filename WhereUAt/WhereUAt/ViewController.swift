//
//  ViewController.swift
//  WhereUAt
//
//  Created by Angel Xiao on 2/25/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, HolderViewDelegate {
    
    var holderView = HolderView(frame:CGRectZero)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()

        transition()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        let mapView = self.view as! GMSMapView
    }

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
        
        
    }

    func backgroundLabel() {
    }
    
    func transition(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        //let secondViewController = storyBoard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        let vc = MapViewController()
        self.presentViewController(vc, animated: true, completion: nil)
    }
}