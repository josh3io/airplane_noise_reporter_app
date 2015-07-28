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
    
    var markers = []
    
    var airplanes = [String:Airplane]()
    
    var locationManager:CLLocationManager = CLLocationManager()
    var doLogoutOnLoad:Bool = false
    var doShowLogin:Bool = false
    
    var initialZoomComplete:Bool = false
    
    var updateTimer:NSTimer = NSTimer()
    var doingUpdateMapFromApi:Bool = false
    
    var shareMessageTextField:UITextField?
    
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
                self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "doUpdateMapFromApi", userInfo: nil, repeats: true)
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
        self.updateTimer = NSTimer.scheduledTimerWithTimeInterval(30, target: self, selector: "doUpdateMapFromApi", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("mapview viewWillAppear")
        super.viewWillAppear(animated);
        mapView.delegate = self
    }
    
    func doUpdateMapFromApi() {
        if (!self.doingUpdateMapFromApi) {
            self.doingUpdateMapFromApi = true
            
            
            myAPI.getAirplaneFeed(doProcessJSONLocations)
        } else {
            println("already updating map locations")
        }
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
            myAPI.selectedPlane = airplanes[anno.title]!
            return annoView
        } else {
            return nil
        }
    }
    
    func mapView(mapView: MKMapView!, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            println("goto mail")
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var setViewController = mainStoryboard.instantiateViewControllerWithIdentifier("SendMailView") as! SendMailViewController
            var rootViewController = appDelegate.window!.rootViewController
            rootViewController?.presentViewController(setViewController, animated: false, completion: nil)

        }
    }

    
    
    func doProcessJSONLocations(data:JSON) {
        let numLat = NSNumber(double: self.location.latitude as Double)
        let stLat:String = numLat.stringValue
        
        let numLon = NSNumber(double: self.location.latitude as Double)
        let stLon:String = numLon.stringValue
        
        var tmpAirplanes = [String:Airplane]()
        var newMarkers:[MapAnnotation] = []
        for (index:String, plane:JSON) in data["list"] {
            let hexIdent = plane["hexIdent"].stringValue
            let altitude = plane["altitude"].stringValue
            let groundSpeed = plane["groundSpeed"].stringValue
            let lat = plane["lat"].doubleValue
            let lon = plane["lon"].doubleValue
            
            var a = Airplane(hexIdent:hexIdent,altitude:altitude,groundSpeed:groundSpeed,lat:lat,lon:lon)
            
            var newMarker = MapAnnotation(coordinate: CLLocationCoordinate2D(latitude:lat,longitude:lon), title: hexIdent, subtitle: altitude+" @ "+groundSpeed)
            newMarkers.append(newMarker)
        }
        
        if (newMarkers.count > 0) {
            airplanes = tmpAirplanes
            
            self.mapView.removeAnnotations(self.markers as [AnyObject])
            self.mapView.addAnnotations(newMarkers)
        }
        self.doingUpdateMapFromApi = false
        
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.updateTimer.invalidate()
        initialZoomComplete = false
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
            let newLoc = obj as! CLLocation
            let theLoc:CLLocationCoordinate2D = newLoc.coordinate
            let theAcc:CLLocationAccuracy = newLoc.horizontalAccuracy
            
            self.location = theLoc
            
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

