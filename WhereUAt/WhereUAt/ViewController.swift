//
//  ViewController.swift
//  WhereUAt
//
//  Created by Angel Xiao on 2/25/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, HolderViewDelegate {

    var holderView = HolderView(frame:CGRectZero)
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        addHolderView()
        
        if(FBSDKAccessToken.currentAccessToken() == nil){
            NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "toLoginViewTransition",
                userInfo: nil, repeats: false)
        } else {
            NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "toMapViewTransition",
                userInfo: nil, repeats: false)
        }
//=======
//        NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "transition",
//            userInfo: nil, repeats: false)
        /* Adding static image of logo to center of navigation bar
        let nav = self.navigationController?.navigationBar
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.contentMode = .ScaleAspectFit
        
        let image = UIImage(named: "AppIconNoBGLarge")
        imageView.image = image
        
        navigationItem.titleView = imageView*/
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    
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
    
    func toMapViewTransition(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyBoard.instantiateViewControllerWithIdentifier("MapViewController") as! MapViewController
        self.presentViewController(secondViewController, animated: true, completion: nil)
    }
    
    func toLoginViewTransition(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyBoard.instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
        self.presentViewController(loginViewController, animated: true, completion: nil)
        
    }
}