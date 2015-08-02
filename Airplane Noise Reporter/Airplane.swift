//
//  Airplane.swift
//  Airplane Noise Reporter
//
//  Created by Josh Goldberg on 7/26/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation

class Airplane :NSObject {
    var hexIdent:String
    var altitude:String
    var groundSpeed:String
    var lat:Double
    var lon:Double
    var updateTime:Double
    
    init(hexIdent h:String, altitude a:String, groundSpeed g:String, lat:Double, lon:Double) {
        hexIdent = h
        altitude = a
        groundSpeed = g
        self.lat = lat
        self.lon = lon
        updateTime = NSDate().timeIntervalSince1970
    }
    
}