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
    
    let prefs = NSUserDefaults.standardUserDefaults()
    var uid = ""
    var name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        if (FBSDKAccessToken.currentAccessToken() == nil) {
            loginButton.readPermissions = ["public_profile", "email", "user_friends"]
        }
        
        loginButton.delegate = self
        
        self.view.addSubview(loginButton)
        
        //old id 1179024952116500
        //old secret 0412aa2064b6aa8caee7b98f270bd2e5
        //new facebook identifier <key>CFBundleURLTypes</key>   <string>688123444662676</string>

    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        if (error == nil) {
//            print("Login complete")
            fetchProfile()
//            self.performSegueWithIdentifier("toMap", sender: self)
            
        }
        else {
            print(error.localizedDescription)
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        let loginManager: FBSDKLoginManager = FBSDKLoginManager()
        loginManager.logOut()
        print("User logged out")
    }
    
    func fetchProfile() {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: parameters).startWithCompletionHandler({ (connection, user, requestError) -> Void in
            
            if requestError != nil {
                print(requestError)
                return
            }
            self.performSegueWithIdentifier("toMap", sender: self)

        })
    }
}