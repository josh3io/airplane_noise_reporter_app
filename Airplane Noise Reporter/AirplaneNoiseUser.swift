//
//  HugzerUser.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/7/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import MapKit

class AirplaneNoiseUser : NSObject
{
    var username:NSString
    var password:NSString = ""
    var lat:CLLocationDegrees = 0
    var lon:CLLocationDegrees = 0
    var error:NSString = ""
    
    override init() {
        self.username = "Anonymous"
    }
    
    init(username:String) {
        self.username = username;
    }
    
    init(username:String,lat:Double,lon:Double) {
        self.username = username;
        self.lat = lat;
        self.lon = lon;
    }
    
    init(username:String,latlon:String) {
        self.username = username;
        var coord = latlon.componentsSeparatedByString(" ")
        self.lat = (coord[0] as NSString).doubleValue;
        self.lon = (coord[1] as NSString).doubleValue;
    }
    
    func location() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
    
    func setUsername(username:String) {
        self.username = username
    }
    func setPassword(password:String) {
        self.password = password
    }
    func setError(error:String) {
        self.error = error
    }
    
}