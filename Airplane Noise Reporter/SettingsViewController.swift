//
//  SettingsViewController.swift
//  Airplane Noise Reporter
//
//  Created by Josh Goldberg on 7/26/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController: UIViewController {
    
    var myAPI:AirplaneNoiseApi
    
    
    
    @IBOutlet weak var name:UITextField!
    @IBOutlet weak var address1:UITextField!
    @IBOutlet weak var address2:UITextField!
    @IBOutlet weak var city:UITextField!
    @IBOutlet weak var zip:UITextField!
    @IBOutlet weak var phone:UITextField!
    
    @IBOutlet weak var error:UILabel!
    
    
    
    
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.myAPI = appDelegate.airplaneNoiseApi
        println("settings init\n")
        //currentPicker = _us_house
        //currentTitle = titles[0]
        super.init(coder: aDecoder)
        
    }
    
    func loadPrefs() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        /*
        let usHouseSetting = prefs.stringForKey("US_HOUSE") ?? "<- Click to choose"
        let caSenateSetting = prefs.stringForKey("CA_SENATE") ?? "<- Click to choose"
        let caAssemblySetting = prefs.stringForKey("CA_ASSEMBLY") ?? "<- Click to choose"
        
        houseLabel.text = usHouseSetting
        senateLabel.text = caSenateSetting
        assemblyLabel.text = caAssemblySetting
        */
        
        name.text = prefs.stringForKey("NAME_KEY") ?? ""
        address1.text = prefs.stringForKey("ADDRESS1_KEY") ?? ""
        address2.text = prefs.stringForKey("ADDRESS2_KEY") ?? ""
        city.text = prefs.stringForKey("CITY_KEY") ?? ""
        zip.text = prefs.stringForKey("ZIP_KEY") ?? ""
        phone.text = prefs.stringForKey("PHONE_KEY") ?? ""
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SettingsView")
        
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    
    
    override func viewDidLoad() {
        
        loadPrefs()
        
        /*
        nameAndAddress.layer.borderWidth = 5.0
        nameAndAddress.layer.borderColor = UIColor.grayColor().CGColor
        nameAndAddress.layer.cornerRadius = 8
        */
        
        super.viewDidLoad()
        
    }
    
    /*
    func textViewDidChange(textView: UITextView) {
    println("textivew did change: \(textView.text)")
    var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    prefs.setObject(textView.text, forKey: "NAME_AND_ADDRESS")
    }
    */
    
    @IBAction func doneButtonTapped(sender:UIButton!) {
        
        if (name.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
            && address1.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
            && city.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0
            && zip.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= 5
            && phone.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                println("everything has length")
                error.hidden = true
                var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
                
                var nameAndAddress = "\(name.text)\n\(address1.text)\n"
                if (address2.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 0) {
                    nameAndAddress += address2.text + "\n"
                }
                nameAndAddress += "\(city.text), CA \(zip.text)\n\(phone.text)"
                
                println(nameAndAddress)
                
                
                prefs.setObject(nameAndAddress, forKey: "NAME_AND_ADDRESS")
                prefs.setObject(name.text, forKey: "NAME_KEY")
                prefs.setObject(address1.text, forKey: "ADDRESS1_KEY")
                prefs.setObject(address2.text, forKey: "ADDRESS2_KEY")
                prefs.setObject(city.text, forKey: "CITY_KEY")
                prefs.setObject(zip.text, forKey: "ZIP_KEY")
                prefs.setObject(phone.text, forKey: "PHONE_KEY")
                
                prefs.setInteger(1,forKey:"ISLOGGEDIN")
                prefs.synchronize()
                
                var tracker = GAI.sharedInstance().defaultTracker
                tracker.set(kGAIScreenName,value:"SettingsView")
                let event = GAIDictionaryBuilder.createEventWithCategory("Settings", action: "tap", label: "DoneButton", value: 1).build() as [NSObject:AnyObject]
                tracker.send(event)
                tracker.set(kGAIScreenName,value:nil)
                
                self.performSegueWithIdentifier("goto_map", sender: self)
        } else {
            error.hidden = false
        }
        
        
    }
    
    
}