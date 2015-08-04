//
//  MapAnnotation.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/10/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import MapKit

let planeIcon = UIImage(named:"rsz_plane.png")

class MapAnnotation : NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String
    var track:Double // direction of travel
    
    var updateTime:Double
    
    var view:MKAnnotationView?

    init(coordinate:CLLocationCoordinate2D,title:String,subtitle:String, updateTime:Double, track:Double) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.track = track
        self.updateTime = updateTime
    }
    
    func updateCoordinate(coordinate:CLLocationCoordinate2D,track:Double) -> Void {
        self.willChangeValueForKey("coordinate")
        self.coordinate = coordinate
        self.didChangeValueForKey("coordinate")
        if (self.view != nil) {
            self.willChangeValueForKey("image")
            self.track = track
            self.setViewImageForTrack(self.view!,track:self.track)
            self.didChangeValueForKey("image")
        }
    }
    
    func getUpdateTime() -> Double {
        return updateTime
    }
    
    func setViewImageForTrack(view:MKAnnotationView,track:Double) -> Void {
        //println("rotate icon to \(track) degrees")
        var realTrack:Double;
        if (track - 90 < 0) {
            realTrack = 360 + (track - 90)
        } else {
            realTrack = track - 90
        }
        println("\(title) data track \(track) rotate image by \(realTrack)")
        let rotatedImage:UIImage = rotateImageByDegrees(planeIcon!, degrees: realTrack)
        view.image = rotatedImage
        
    }
    
    func annotationView() -> MKAnnotationView {
        var view:MKAnnotationView = MKAnnotationView(annotation: self, reuseIdentifier: "MapAnnotationView")
        view.enabled = true
        view.canShowCallout = true
        
        setViewImageForTrack(view,track:self.track)
        
        let image:UIImage = UIImage(named: "exclaimation point.png")!
        var theButton:UIButton = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size:image.size))
        theButton.setImage(image,forState:UIControlState.Normal);
        view.rightCalloutAccessoryView = theButton
        //view.rightCalloutAccessoryView = UIButton.buttonWithType(.InfoDark) as! UIButton
        return view
    }

    func rotateImageByDegrees(sourceImage:UIImage, degrees:Double) -> UIImage {
        let radians:CGFloat = degreesToRadians(CGFloat(degrees))
        var viewBox:UIView = UIView(frame: CGRectMake(0,0,sourceImage.size.width,sourceImage.size.height))
        let transform:CGAffineTransform = CGAffineTransformMakeRotation(radians)
        viewBox.transform = transform
        let rotatedSize:CGSize = viewBox.frame.size
        
        println("\(title) heading \(degrees) radians \(radians)")
        
        UIGraphicsBeginImageContextWithOptions(rotatedSize, false, UIScreen.mainScreen().scale)
        var bitmap:CGContextRef = UIGraphicsGetCurrentContext()
        
        CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2)
        CGContextRotateCTM(bitmap, radians)
        CGContextScaleCTM(bitmap, 1.0, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-sourceImage.size.width/2, -sourceImage.size.height/2, sourceImage.size.width, sourceImage.size.height), sourceImage.CGImage)
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func degreesToRadians(degrees:CGFloat) -> CGFloat {
        return degrees * CGFloat(M_PI) / 180.0;
    }
}