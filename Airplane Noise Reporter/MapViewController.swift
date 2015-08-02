//
//  ViewController.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/7/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var shareSwitch: UISwitch!
    @IBOutlet weak var RightNavItem: UIBarButtonItem!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet var mapViewTap: UITapGestureRecognizer!
    
    var myAPI:AirplaneNoiseApi
    
    var location:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    var markers = [MapAnnotation]()
    var markersLookup = [String:MapAnnotation]()
    
    var airplanes = [String:Airplane]()
    
    var locationManager:CLLocationManager = CLLocationManager()
    var doLogoutOnLoad:Bool = false
    var doShowLogin:Bool = false
    
    var initialZoomComplete:Bool = false
    var initialCenterComplete:Bool = false
    
    var updateTimer:NSTimer = NSTimer()
    var doingUpdateMapFromApi:Double = 0
    
    var doingMapChange = false
    
    var shareMessageTextField:UITextField?
    
    var reportHexId:String = ""
    
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.myAPI = appDelegate.airplaneNoiseApi
        println("map view init\n")
        self.locationManager.requestWhenInUseAuthorization()
        super.init(coder: aDecoder)
    }
    
    @IBAction func zoomIn(sender: AnyObject){
        
        let userLocation = mapView.userLocation
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 2000, 2000)
        
        mapView.setRegion(region, animated: true)
    }
    @IBAction func changeMapType(sender:AnyObject){
        if mapView.mapType == MKMapType.Standard {
            mapView.mapType = MKMapType.Satellite
        } else {
            mapView.mapType = MKMapType.Standard
        }
    }
    
    
    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        mapView.centerCoordinate = userLocation.location.coordinate
        if (initialZoomComplete == false) {
            let userLocation = mapView.userLocation
            let region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 75000, 75000)
            let adjustedRegion = mapView.regionThatFits(region)
            mapView.setRegion(adjustedRegion, animated: true)
            
            initialZoomComplete = true
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let id:String = segue.identifier! as String
        if (id == "goto_login") {
            //let destVC = segue.destinationViewController as LoginViewController
            //destVC.doLogout = true
        } else if (id == "showSendReport") {
            let destVC = segue.destinationViewController as! SendMailViewController
            destVC.thePlane = airplanes[reportHexId]
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        println("mapview did appear")
        if self.doShowLogin {
            self.doShowLogin = false
            
            
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
            let username:NSString = prefs.valueForKey("USERNAME") as! NSString
            println("loggedin \(isLoggedIn); username \(username)")
            
            let shareState:Bool = (prefs.valueForKey("SHARESTATE") ?? false) as! Bool
            
            if (!self.updateTimer.valid) {
                self.doUpdateMapFromApi()
                self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "doUpdateMapFromApi", userInfo: nil, repeats: true)
            }
            
            
            
        }
    }
    override func viewDidLoad() {
        println("mapview did load")
        super.viewDidLoad()
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let isLoggedIn:Int = prefs.integerForKey("ISLOGGEDIN") as Int
        
        if (self.doLogoutOnLoad) {
            println("do logout on load")
        }
        
        if (isLoggedIn != 1 || self.doLogoutOnLoad) {
            println("go do login")
            self.doLogoutOnLoad = false
            self.doShowLogin = true
        } else {
            println("no need to do login")
            let username:NSString = prefs.valueForKey("USERNAME") as! NSString
            let password:NSString = prefs.valueForKey("PASSWORD") as! NSString
            
            
            myAPI.login(username, password:password, callback: {user -> Void in })
        }
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        println("mapview request authorization")
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        
        self.doUpdateMapFromApi()
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "doUpdateMapFromApi", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("mapview viewWillAppear")
        super.viewWillAppear(animated);
        mapView.delegate = self
    }
    
    func doUpdateMapFromApi() {
        myAPI.getAirplaneFeed(doProcessJSONLocations)
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if (annotation.isKindOfClass(MapAnnotation)) {
            var anno:MapAnnotation = annotation as! MapAnnotation
            var annoView = mapView.dequeueReusableAnnotationViewWithIdentifier("MapAnnotationView")
            
            if (annoView == nil) {
                println("new annotationView")
                annoView = anno.annotationView()
                return annoView
            } else {
                println("got a reusable view")
                annoView.annotation = anno
            }
            //myAPI.selectedPlane = airplanes[anno.title]
            return annoView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            println("goto mail")
            reportHexId = annotationView.annotation.title!
            self.performSegueWithIdentifier("showSendReport", sender: self)
        }
    }
    
    
    func doProcessJSONLocations(data:JSON) {
        let now:Double = NSDate().timeIntervalSince1970
        let numLat = NSNumber(double: self.location.latitude as Double)
        let stLat:String = numLat.stringValue
        
        let numLon = NSNumber(double: self.location.latitude as Double)
        let stLon:String = numLon.stringValue
        
        var airplaneInNewList = [String:Bool]()
        for (index:String, plane:JSON) in data["list"] {
            let hexId:String = plane["hexIdent"].stringValue
            
            airplaneInNewList[hexId] = true
            
            println("process plane \(hexId)")
            let altitude = plane["altitude"].stringValue
            let groundSpeed = plane["groundSpeed"].stringValue
            let lat = plane["lat"].doubleValue
            let lon = plane["lon"].doubleValue
            
            if (airplanes[hexId] != nil) {
                // update existing plane
                println("update plane \(hexId)")
                airplanes[hexId]!.altitude = altitude
                airplanes[hexId]!.groundSpeed = groundSpeed
                airplanes[hexId]!.lat = lat
                airplanes[hexId]!.lon = lon
                airplanes[hexId]!.updateTime = now
            } else {
                println("add plane \(hexId)")
                airplanes[hexId] = Airplane(hexIdent:hexId,altitude:altitude,groundSpeed:groundSpeed,lat:lat,lon:lon)
            }
        }
        
        var markerExists = [String:Bool]()
        for (hexId:String,anno:MapAnnotation) in markersLookup {
            if (airplaneInNewList[hexId] == nil) {
                // not in data set; remove it
                println("not in data set, remove \(hexId)")
                airplanes.removeValueForKey(hexId)
                mapView.removeAnnotation(markersLookup[hexId])
                markersLookup.removeValueForKey(hexId)
                markerExists[hexId] = false
            } else if (airplanes[hexId] != nil) {
                if (markersLookup[hexId]!.updateTime <= airplanes[hexId]!.updateTime) {
                    println("update marker coords \(hexId)")
                    markersLookup[hexId]!.updateTime = airplanes[hexId]!.updateTime
                    markersLookup[hexId]!.updateCoordinate(CLLocationCoordinate2D(latitude:airplanes[hexId]!.lat,longitude:airplanes[hexId]!.lon))
                    markerExists[hexId] = true
                    
                } else if (markersLookup[hexId]!.updateTime < now - 300) {
                    // too old, remove it
                    println("too old, remove marker \(hexId)")
                    mapView.removeAnnotation(markersLookup[hexId])
                    markersLookup.removeValueForKey(hexId)
                    markerExists[hexId] = false
                } else {
                    // skip because the marker is newer than the record from JSON
                    println("skip \(hexId)")
                    markerExists[hexId] = true
                    
                }
            } else {
                // we don't know about the airplane for some reason?
                println("skip unknown marker \(hexId)")
                println("removing found marker without matching plane: \(hexId)")
                mapView.removeAnnotation(markersLookup[hexId])
                markersLookup.removeValueForKey(hexId)
                markerExists[hexId] = false
            }
            
        }
        for (hexId:String, plane:Airplane) in airplanes {
            if (markerExists[hexId] == nil) {
                // new marker because we didn't find one in the existing markersLookup set
                println("need a new marker for \(hexId)")
                let lat = airplanes[hexId]!.lat
                let lon = airplanes[hexId]!.lon
                let groundSpeed = airplanes[hexId]!.groundSpeed
                let altitude = airplanes[hexId]!.altitude
                
                let newMarker = MapAnnotation(coordinate: CLLocationCoordinate2D(latitude:lat,longitude:lon), title: hexId, subtitle: "\(groundSpeed)kts @ \(altitude)ft", updateTime:now)
                mapView.addAnnotation(newMarker)
                markersLookup[hexId] = newMarker
            }
        }
        myAPI.airplanes = airplanes
    }
    
    func doProcessJSONLocationsOld(data:JSON) {
        let numLat = NSNumber(double: self.location.latitude as Double)
        let stLat:String = numLat.stringValue
        
        let numLon = NSNumber(double: self.location.latitude as Double)
        let stLon:String = numLon.stringValue
        
        var newMarkers:[MapAnnotation] = []
        var newIdents = [String:Bool]()
        var minNow:Double = 9999999999
        if (self.doingUpdateMapFromApi == 0) {
            self.doingUpdateMapFromApi = NSDate().timeIntervalSince1970
            for (index:String, plane:JSON) in data["list"] {
                if (plane["lastUpdateTimestamp"].doubleValue > self.doingUpdateMapFromApi - 120) {
                    println("json plane "+plane["hexIdent"].stringValue)
                    
                    let hexIdent = plane["hexIdent"].stringValue
                    let altitude = plane["altitude"].stringValue
                    let groundSpeed = plane["groundSpeed"].stringValue
                    let lat = plane["lat"].doubleValue
                    let lon = plane["lon"].doubleValue
                    
                    var a = Airplane(hexIdent:hexIdent,altitude:altitude,groundSpeed:groundSpeed,lat:lat,lon:lon)
                    
                    let newMarker = MapAnnotation(coordinate: CLLocationCoordinate2D(latitude:lat,longitude:lon), title: hexIdent, subtitle: "\(groundSpeed)kts @ \(altitude)ft", updateTime:plane["lastUpdateTimestamp"].doubleValue)
                    
                    newMarkers.append(newMarker)
                    newIdents[hexIdent] = true
                }
            }
        }
        print("newMarkers count \(newMarkers.count)")
        var oldIdents = [String:Bool]()
        var markers = [MapAnnotation]()
        let now:Double = NSDate().timeIntervalSince1970
        for (anno:MapAnnotation) in self.markers {
            if (anno.view?.highlighted == true) {
                oldIdents[anno.title] = true
            }
            else if (anno.getUpdateTime() < now - 300) {
                println("remove old by expiry for \(anno.title)")
                self.mapView.removeAnnotation(anno)
                oldIdents[anno.title] = false
            }
            else if (newIdents[anno.title] != nil) {
                println("remove old for \(anno.title)")
                self.mapView.removeAnnotation(anno)
                oldIdents[anno.title] = false
            }
            else if (oldIdents[anno.title] != true) {
                oldIdents[anno.title] = true
                markers.append(anno)
            }
        }
        for (anno:MapAnnotation) in newMarkers {
            if (oldIdents[anno.title] != true) {
                println("add new for \(anno.title)")
                markers.append(anno)
            }
        }
        self.mapView.addAnnotations(newMarkers)
        self.markers = markers
        
        if (!doingMapChange) {
            var center:CLLocationCoordinate2D  = self.mapView.centerCoordinate
            var forceChange:CLLocationCoordinate2D = CLLocationCoordinate2DMake(center.latitude-1,center.longitude-1)
            self.mapView.centerCoordinate = forceChange
            self.mapView.centerCoordinate = center
        }
        
        
        self.doingUpdateMapFromApi = 0
        println("unset doingUpdateMapFromApi")
        
        
    }
    
    func mapView(mapView:MKMapView, regionDidChangeAnimated animated:Bool) {
        doingMapChange = false
    }
    func mapView(mapView:MKMapView, regionWillChangeAnimated animated:Bool) {
        doingMapChange = true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateTimer.invalidate()
        initialZoomComplete = false
        initialCenterComplete = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            manager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
        default: break
        }
    }
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]) {
        
        //println("map location manager didUpdateLocations")
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        for obj in locations  {
            if (!initialCenterComplete) {
                let newLoc = obj as! CLLocation
                let theLoc:CLLocationCoordinate2D = newLoc.coordinate
                let theAcc:CLLocationAccuracy = newLoc.horizontalAccuracy
                
                self.location = theLoc
                initialCenterComplete = true
            }
            
        }
    }
    
    @IBAction func handleShareSwitch(sender: UISwitch) {
        if (sender.on) {
            let alertController = UIAlertController(title:"Share Location", message:"What do you have to say?", preferredStyle: .Alert)
            
            alertController.addTextFieldWithConfigurationHandler({(textField:UITextField!) in
                textField.placeholder = "message"
                self.shareMessageTextField = textField
            })
            
            
            alertController.addAction(UIAlertAction(title:"OK", style:.Default, handler: self.turnitonAction))
            alertController.addAction(UIAlertAction(title:"Cancel", style:.Default, handler: self.shutitoffAction))
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.shutitoff()
        }
    }
    
    func shutitoffAction(action:UIAlertAction!) {
        shareSwitch.setOn(false, animated: shareSwitch.on)
        self.shutitoff()
    }
    func shutitoff() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setBool(false, forKey: "SHARESTATE")
        prefs.synchronize()
    }
    func turnitonAction(action:UIAlertAction!) {
        self.turniton(self.shareMessageTextField?.text as String!)
    }
    func turniton(message:String) {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        prefs.setBool(true, forKey: "SHARESTATE")
        prefs.setObject(message, forKey: "SHAREMESSAGE")
        prefs.synchronize()
    }
    
}

