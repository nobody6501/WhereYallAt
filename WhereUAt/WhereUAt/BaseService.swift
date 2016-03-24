//
//  BaseService.swift
//  WhereUAt
//
//  Created by Martin Huang on 3/19/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import Foundation
import Firebase

let BASE_URL = "https://amber-torch-9345.firebaseio.com/"

let FIREBASE_ROOT = Firebase(url: BASE_URL)

var CURRENT_USER: Firebase {
    let userID = NSUserDefaults.standardUserDefaults().valueForKey("uid") as! String
    
    let currentUser = Firebase(url: "\(FIREBASE_ROOT)").childByAppendingPath("users").childByAppendingPath(userID)
    return currentUser!
}

