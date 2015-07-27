//
//  MapAnnotation.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/10/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import MapKit

class MapAnnotation : NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    
    var view:MKAnnotationView?

    init(coordinate:CLLocationCoordinate2D,title:String,subtitle:String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    func annotationView() -> MKAnnotationView {
        var view:MKAnnotationView = MKAnnotationView(annotation: self, reuseIdentifier: "MapAnnotationView")
        view.enabled = true
        view.canShowCallout = true
        view.image = UIImage(named: "rsz_plane.png")
        
        
        return view
    }
}