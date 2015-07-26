//
//  LocationShareManager.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/9/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import CoreLocation

class LocationShareModel : NSObject {
    var anotherLocationManager:CLLocationManager?
    var myLocationDictInPlist:NSMutableDictionary?
    var myLocationArrayInPlist:NSMutableArray?
    
    var shareLocation:Bool?
    var afterResume:Bool?
    
    class var sharedModel:LocationShareModel {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: LocationShareModel? = nil
            
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = LocationShareModel()
        }
        return Static.instance!
    }
    
}