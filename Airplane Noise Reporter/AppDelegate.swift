//
//  AppDelegate.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/7/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    
    var locationUpdateTimer:NSTimer?
    
    var airplaneNoiseApi:AirplaneNoiseApi = AirplaneNoiseApi()
    
    var shareModel = LocationShareModel.sharedModel
    var myLastLocation:CLLocationCoordinate2D?
    var myLastLocationAccuracy:CLLocationAccuracy?
    var myLocation:CLLocationCoordinate2D?
    var myLocationAccuracy:CLLocationAccuracy?
    
    func getLocationManager() -> Void {
        self.shareModel.anotherLocationManager = CLLocationManager()
        self.shareModel.anotherLocationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.shareModel.anotherLocationManager?.activityType = CLActivityType.OtherNavigation
        self.shareModel.anotherLocationManager?.requestWhenInUseAuthorization()
        
        self.shareModel.anotherLocationManager?.startMonitoringSignificantLocationChanges()
    }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        println("finished loading")
        
        shareModel.afterResume = false
        shareModel.shareLocation = false
        
        self.addApplicationStatusToPList("didFinishLaunchingWithOptions")
        
        println("continue loading")
        
        getLocationManager()
        
        
        println("locKey is nil")
        self.shareModel.afterResume = false
        self.addLocationToPList(false)
        
        println("done application")
        return true
    }
    
    
    
    func stopSharingLocation() -> Void {
        self.shareModel.shareLocation = false
        self.airplaneNoiseApi.removeLocation();
    }
    
    func startSharingLocation(message:String) -> Void {
        self.shareModel.shareLocation = true
        self.airplaneNoiseApi.initLocation(message);
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]) {
        for obj in locations {
            let newLoc:CLLocation = obj as! CLLocation
            let theLoc:CLLocationCoordinate2D = newLoc.coordinate
            let theAcc:CLLocationAccuracy = newLoc.horizontalAccuracy
            
            self.myLocation = theLoc
            self.myLocationAccuracy = theAcc
        }
        self.addLocationToPList(self.shareModel.afterResume!)
    }
    
    
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        
        
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.shareModel.anotherLocationManager?.stopMonitoringSignificantLocationChanges()
        self.shareModel.anotherLocationManager?.requestWhenInUseAuthorization()
        self.shareModel.anotherLocationManager?.startMonitoringSignificantLocationChanges()
        self.addApplicationStatusToPList("applicationDidEnterBackground")
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.addApplicationStatusToPList("applicationDidBecomeActive")
        
        self.shareModel.afterResume = false
        if (self.shareModel.anotherLocationManager != nil) {
            self.shareModel.anotherLocationManager?.stopMonitoringSignificantLocationChanges()
        }
        
        let locationManager = CLLocationManager()
        self.shareModel.anotherLocationManager = locationManager
        self.shareModel.anotherLocationManager?.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.shareModel.anotherLocationManager?.activityType = CLActivityType.OtherNavigation
        self.shareModel.anotherLocationManager?.requestWhenInUseAuthorization()
        
        self.shareModel.anotherLocationManager?.startMonitoringSignificantLocationChanges()
        
        
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        self.addApplicationStatusToPList("applicationWillTerminate")
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.threeio.Hugzer" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Hugzer", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Hugzer.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            let dict = NSMutableDictionary()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict as [NSObject : AnyObject])
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
    func addResumeLocationToPList() {
        let app:UIApplication = UIApplication.sharedApplication()
        var appState:String?
        
        switch app.applicationState {
        case UIApplicationState.Active:
            appState = "UIApplicationStateActive"
            break;
        case UIApplicationState.Background:
            appState = "UIApplicationStateBackground"
            break;
        case UIApplicationState.Inactive:
            appState = "UIApplicationStateInactive"
        }
        
        self.shareModel.myLocationDictInPlist = NSMutableDictionary()
        self.shareModel.myLocationDictInPlist?.setObject("UIApplicationLaunchOptionsLocationKey", forKey: "applicationStatus")
        self.shareModel.myLocationDictInPlist?.setObject(appState!, forKey: "Resume")
        self.shareModel.myLocationDictInPlist?.setObject(NSDate(), forKey: "Time")
        
        let plistName:NSString = "LocationArray.plist"
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docDir:NSString = paths.objectAtIndex(0) as! NSString
        
        let fileManager = NSFileManager.defaultManager()
        
        let fullPath:NSString = docDir.stringByAppendingPathComponent(plistName as String)
        if (!(fileManager.fileExistsAtPath(fullPath as String))) {
            println("creating file \(fullPath)")
            var bundle:NSString = NSBundle.mainBundle().pathForResource("LocationArray", ofType: "plist")!
            var err:NSError?
            fileManager.copyItemAtPath(bundle as String, toPath: fullPath as String, error: &err)
            if ((err) != nil) {
                println("error creating file: \(err?.description)")
            } else {
                println("file created OK")
            }
        }
        
        
        var myDict = NSDictionary(contentsOfFile: fullPath as String)
        var savedProfile:NSMutableDictionary = myDict?.mutableCopy() as! NSMutableDictionary
        
        if savedProfile.count > 0 {
            
            self.shareModel.myLocationArrayInPlist = savedProfile.objectForKey("LocationArray") as? NSMutableArray
        } else {
            savedProfile = NSMutableDictionary()
            self.shareModel.myLocationArrayInPlist = NSMutableArray()
        }
        
        if ((self.shareModel.myLocationArrayInPlist) != nil) {
            self.shareModel.myLocationArrayInPlist?.addObject(self.shareModel.myLocationDictInPlist!)
            savedProfile.setObject(self.shareModel.myLocationArrayInPlist!, forKey: "LocationArray")
        }
        
        if (!savedProfile.writeToFile(fullPath as String, atomically: false)) {
            NSLog("Couldn't save LocationArray.plist for resume location")
        }
        self.doApiUpdateLocation()
    }
    
    func getStateString(state:UIApplicationState) -> String {
        if state == UIApplicationState.Active {
            return "UIApplicationStateActive"
        } else if state == UIApplicationState.Background {
            return "UIApplicationStateBackground"
        } else if state == UIApplicationState.Inactive {
            return "UIApplicationStateInactive"
        } else {
            return "NONE"
        }
    }
    
    func addLocationToPList(fromResume:Bool) {
        let app:UIApplication = UIApplication.sharedApplication()
        var appState:String = getStateString(app.applicationState);
        
        if (self.myLocation == nil) {
            println("no location to add, returning")
            return
        }
        
        self.shareModel.myLocationDictInPlist = NSMutableDictionary()
        self.shareModel.myLocationDictInPlist?.setObject(NSNumber(double: (self.myLocation?.latitude)!),forKey:"Latitude")
        self.shareModel.myLocationDictInPlist?.setObject(NSNumber(double: (self.myLocation?.longitude)!),forKey:"Longitude")
        self.shareModel.myLocationDictInPlist?.setObject(NSNumber(double: self.myLocationAccuracy!),forKey:"Accuracy")
        self.shareModel.myLocationDictInPlist?.setObject(appState, forKey: "AppState")
        
        if (fromResume) {
            self.shareModel.myLocationDictInPlist?.setObject("YES", forKey: "AddFromResume")
        } else {
            self.shareModel.myLocationDictInPlist?.setObject("NO", forKey: "AddFromResume")
        }
        
        let plistName:NSString = "LocationArray.plist"
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docDir:NSString = paths.objectAtIndex(0) as! NSString
        
        let fileManager = NSFileManager.defaultManager()
        
        let fullPath:NSString = docDir.stringByAppendingPathComponent(plistName as String)
        if (!(fileManager.fileExistsAtPath(fullPath as String))) {
            println("creating file \(fullPath)")
            var bundle:NSString = NSBundle.mainBundle().pathForResource("LocationArray", ofType: "plist")!
            var err:NSError?
            fileManager.copyItemAtPath(bundle as String, toPath: fullPath as String, error: &err)
            if ((err) != nil) {
                println("error creating file: \(err?.description)")
            } else {
                println("file created OK")
            }
        }
        
        
        var myDict = NSDictionary(contentsOfFile: fullPath as String)
        var savedProfile:NSMutableDictionary = myDict?.mutableCopy() as! NSMutableDictionary
        
        if savedProfile.count > 0 {
            
            self.shareModel.myLocationArrayInPlist = savedProfile.objectForKey("LocationArray") as? NSMutableArray
        } else {
            savedProfile = NSMutableDictionary()
            self.shareModel.myLocationArrayInPlist = NSMutableArray()
        }
        
        if ((self.shareModel.myLocationArrayInPlist) != nil) {
            self.shareModel.myLocationArrayInPlist?.addObject(self.shareModel.myLocationDictInPlist!)
            savedProfile.setObject(self.shareModel.myLocationArrayInPlist!, forKey: "LocationArray")
        }
        
        if (!savedProfile.writeToFile(fullPath as String, atomically: false)) {
            NSLog("Couldn't save LocationArray.plist for location")
        }
        self.doApiUpdateLocation()
    }
    
    func setShareSwitchState(state:Bool) -> Void {
        self.shareModel.shareLocation = state
    }
    
    func doApiUpdateLocation() -> Void {
        var searchable:String
        if self.shareModel.shareLocation ?? false {
            searchable = "1"
        } else {
            searchable = "0"
        }
        let numLat = NSNumber(double: (self.myLocation?.latitude)! as Double)
        let stLat:String = numLat.stringValue
        
        let numLon = NSNumber(double: (self.myLocation?.latitude)! as Double)
        let stLon:String = numLon.stringValue
        
        self.airplaneNoiseApi.updateLocation(stLat, lon: stLon, searchable: searchable)
        
    }
    
    func addApplicationStatusToPList(applicationStatus:NSString) {
        let app:UIApplication = UIApplication.sharedApplication()
        var appState:String?
        
        switch app.applicationState {
        case UIApplicationState.Active:
            appState = "UIApplicationStateActive"
            break;
        case UIApplicationState.Background:
            appState = "UIApplicationStateBackground"
            break;
        case UIApplicationState.Inactive:
            appState = "UIApplicationStateInactive"
        }
        
        self.shareModel.myLocationDictInPlist = NSMutableDictionary()
        self.shareModel.myLocationDictInPlist?.setObject(applicationStatus, forKey: "applicationStatus")
        self.shareModel.myLocationDictInPlist?.setObject(appState!, forKey: "AppState")
        self.shareModel.myLocationDictInPlist?.setObject(NSDate(), forKey: "Time")
        
        let plistName:NSString = "LocationArray.plist"
        let paths:NSArray = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docDir:NSString = paths.objectAtIndex(0) as! NSString
        
        let fileManager = NSFileManager.defaultManager()
        
        let fullPath:NSString = docDir.stringByAppendingPathComponent(plistName as String)
        if (!(fileManager.fileExistsAtPath(fullPath as String))) {
            println("creating file \(fullPath)")
            var bundle:NSString = NSBundle.mainBundle().pathForResource("LocationArray", ofType: "plist")!
            var err:NSError?
            fileManager.copyItemAtPath(bundle as String, toPath: fullPath as String, error: &err)
            if ((err) != nil) {
                println("error creating file: \(err?.description)")
            } else {
                println("file created OK")
            }
        }
        
        
        var myDict = NSDictionary(contentsOfFile: fullPath as String)
        var savedProfile:NSMutableDictionary = myDict?.mutableCopy() as! NSMutableDictionary
        
        if savedProfile.count > 0 {
            
            self.shareModel.myLocationArrayInPlist = savedProfile.objectForKey("LocationArray") as? NSMutableArray
        } else {
            savedProfile = NSMutableDictionary()
            self.shareModel.myLocationArrayInPlist = NSMutableArray()
        }
        
        if ((self.shareModel.myLocationArrayInPlist) != nil) {
            self.shareModel.myLocationArrayInPlist?.addObject(self.shareModel.myLocationDictInPlist!)
            savedProfile.setObject(self.shareModel.myLocationArrayInPlist!, forKey: "LocationArray")
        } else {
            println("failed to set LocationArray object")
        }
        
        if (!(savedProfile.writeToFile(fullPath as String, atomically: false))) {
            NSLog("Couldn't save LocationArray.plist for status; file \(fullPath)")
        }
        
    }
    
    
    
}

