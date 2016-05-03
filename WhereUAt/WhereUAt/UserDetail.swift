//
//  UserDetail.swift
//  WhereUAt
//
//  Created by Martin Huang on 4/20/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import Foundation

class UserDetail{
    
    //create a singleton
    static let sharedInstance = UserDetail()
    private init(){}    //make it explicit singleton
    
    func saveUserName(username:String, key:String){
        if let _ = NSUserDefaults.standardUserDefaults().objectForKey(key){
            return      //we already have
            //or choose to edit it and save it again
        }else{
            NSUserDefaults.standardUserDefaults().setObject(username, forKey: key)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func getUserName(key:String)->String?{
        return NSUserDefaults.standardUserDefaults().objectForKey(key) as? String
    }
    
}