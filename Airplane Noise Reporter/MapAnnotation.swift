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
        //println("updateCoordinate (\(coordinate.latitude),\(coordinate.longitude)), \(track)")
        let cSet = CoordinateSet(coordinate: coordinate,track:track)
        tryUpdateCoordinate(cSet)
    }
    
    private struct CoordinateSet {
        var coordinate:CLLocationCoordinate2D;
        var track:Double;
        init() {
            self.coordinate = CLLocationCoordinate2D()
            self.track = 0.0
        }
        init(coordinate:CLLocationCoordinate2D,track:Double) {
            //println("init coordinate (\(coordinate.latitude),\(coordinate.longitude)), \(track)")
            self.coordinate = coordinate
            self.track = track
        }
    }
    
    var coordinateTimer:NSTimer = NSTimer()
    
    func setCoordinateTimer(coordinate:CLLocationCoordinate2D,track:Double) -> Void {
        println("setCoordinateTimer (\(coordinate.latitude),\(coordinate.longitude)), \(track)")
        let cSet = CoordinateSet(coordinate: coordinate,track:track)
        
        self.coordinateTimer = NSTimer.scheduledTimerWithTimeInterval(0.5,target:self,selector:"onTick",userInfo:cSet as? AnyObject,repeats:true);
    }
    
    func onTick(timer:NSTimer) {
        let cSet = timer.userInfo as! CoordinateSet
        println("onTick (\(coordinate.latitude),\(coordinate.longitude)), \(track)")
        let didUpdate = tryUpdateCoordinate(timer.userInfo as! CoordinateSet);
        if (didUpdate == true) {
            self.coordinateTimer.invalidate()
        } else {
            
            
            setCoordinateTimer(cSet.coordinate,track: cSet.track);
        }
    }
    
    private func tryUpdateCoordinate(cSet:CoordinateSet) -> Bool {
        //println("try (\(cSet.coordinate.latitude),\(cSet.coordinate.longitude)), \(cSet.track)")
        //println("view \(self.view)")
        if (self.view != nil) {
            //println("got a view")
            if (self.coordinate.latitude != cSet.coordinate.latitude || self.coordinate.longitude != cSet.coordinate.longitude) {
                println("set coorindate (\(cSet.coordinate.latitude),\(cSet.coordinate.longitude))")
                self.willChangeValueForKey("coordinate")
                //self.coordinate = cSet.coordinate
                
                self.didChangeValueForKey("coordinate")
            }
            
            if (self.track != cSet.track) {
                //println("set track \(cSet.track)")
                self.willChangeValueForKey("image")
                self.track = cSet.track
                self.setViewImageForTrack(self.view!,track:self.track)
                self.didChangeValueForKey("image")
            }
            
            return true;
        } else {
            //println("no view")
            return false
        }
    }
    
    func getUpdateTime() -> Double {
        return updateTime
    }
    
    func setViewImageForTrack(view:MKAnnotationView,track:Double) -> Void {
        //println("rotate icon to \(track) degrees")
        
        //println("\(title) data track \(track)")
        let rotatedImage:UIImage = rotateImageByDegrees(planeIcon!, degrees: track)
        view.image = rotatedImage
        
    }
    
    func annotationView() -> MKAnnotationView {
        view = MKAnnotationView(annotation: self, reuseIdentifier: "MapAnnotationView")
        view!.enabled = true
        view!.canShowCallout = true
        
        //setViewImageForTrack(view,track:self.track)
        
        let image:UIImage = UIImage(named: "exclaimation point.png")!
        var theButton:UIButton = UIButton(frame: CGRect(origin: CGPoint(x:0,y:0), size:image.size))
        theButton.setImage(image,forState:UIControlState.Normal);
        view!.rightCalloutAccessoryView = theButton
        
        
        return view!
    }
    
    func rotateImageByDegrees(sourceImage:UIImage, degrees:Double) -> UIImage {
        let radians:CGFloat = degreesToRadians(CGFloat(degrees))
        var viewBox:UIView = UIView(frame: CGRectMake(0,0,sourceImage.size.width,sourceImage.size.height))
        let transform:CGAffineTransform = CGAffineTransformMakeRotation(radians)
        viewBox.transform = transform
        let rotatedSize:CGSize = viewBox.frame.size
        
        //println("\(title) heading \(degrees) radians \(radians)")
        
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