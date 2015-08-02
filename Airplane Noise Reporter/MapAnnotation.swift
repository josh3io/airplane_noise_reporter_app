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
    
    var updateTime:Double
    
    var view:MKAnnotationView?

    init(coordinate:CLLocationCoordinate2D,title:String,subtitle:String, updateTime:Double) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.updateTime = updateTime
    }
    
    func updateCoordinate(coordinate:CLLocationCoordinate2D) -> Void {
        self.willChangeValueForKey("coordinate")
        self.coordinate = coordinate
        self.didChangeValueForKey("coordinate")
    }
    
    func getUpdateTime() -> Double {
        return updateTime
    }
    
    func annotationView() -> MKAnnotationView {
        var view:MKAnnotationView = MKAnnotationView(annotation: self, reuseIdentifier: "MapAnnotationView")
        view.enabled = true
        view.canShowCallout = true
        view.image = UIImage(named: "rsz_plane.png")
        
        let image:UIImage = UIImage(named: "exclaimation point.png")!
        var theButton:UIButton = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size:image.size))
        theButton.setImage(image,forState:UIControlState.Normal);
        view.rightCalloutAccessoryView = theButton
        //view.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as! UIButton
        return view
    }
}