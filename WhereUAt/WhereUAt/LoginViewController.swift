//
//  LoginViewController.swift
//  WhereUAt
//
//  Created by Martin Huang on 3/19/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import Foundation
import UIKit
import FBSDKLoginKit
import FBSDKCoreKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        print("not logged in yet")
        
        loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        
        loginButton.delegate = self
        
        self.view.addSubview(loginButton)
        
        //old id 1179024952116500
        //old secret 0412aa2064b6aa8caee7b98f270bd2e5
        //new facebook identifier <key>CFBundleURLTypes</key>   <string>688123444662676</string>

    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error == nil) {
            
            print("Login complete")
            self.performSegueWithIdentifier("toMap", sender: self)
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }
}