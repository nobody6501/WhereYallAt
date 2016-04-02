//
//  ColorPointAnnotation.swift
//  WhereUAt
//
//  Created by Martin Huang on 3/29/16.
//  Copyright © 2016 WhereUAt. All rights reserved.
//

import UIKit
import MapKit

class ColorPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor
    init(pinColor: UIColor) {
        self.pinColor = pinColor
        super.init()
    }
    
        
}