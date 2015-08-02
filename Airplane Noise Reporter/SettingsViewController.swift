//
//  SettingsViewController.swift
//  Airplane Noise Reporter
//
//  Created by Josh Goldberg on 7/26/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import UIKit


class SettingsViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    var myAPI:AirplaneNoiseApi
    
    let _us_house = ["District 18","District 20"]
    let _us_house_emails = ["josh+ushouse18@3io.com","josh+ushouse20@3io.com"]
    let _ca_senate = ["District 17","District 13","District 15"]
    let _ca_senate_emails = ["josh+casenate17@3io.com","josh+casenate13@3io.com","josh+casenate15@3io.com"]
    let _ca_assembly = ["District 29","District 28"]
    let _ca_assembly_emails = ["josh+assy29@3io.com","josh+assy28@3io.com"]
    let titles = ["US House","CA Senate","CA Assembly"]
    
    var currentPicker:Array<String>
    var currentTitle:String
    var currentRow:Int = 0
    var usHouseSetting = ""
    var caSenateSetting = ""
    var caAssemblySetting = ""
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var senateLabel: UILabel!
    @IBOutlet weak var assemblyLabel: UILabel!
    
    @IBOutlet weak var pickerViewView:UIView!
    
    
    
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.myAPI = appDelegate.airplaneNoiseApi
        println("settings init\n")
        currentPicker = _us_house
        currentTitle = titles[0]
        super.init(coder: aDecoder)
        
    }
    
    func loadPrefs() {
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        usHouseSetting = prefs.stringForKey("US_HOUSE") ?? "<- Click to choose"
        caSenateSetting = prefs.stringForKey("CA_SENATE") ?? "<- Click to choose"
        caAssemblySetting = prefs.stringForKey("CA_ASSEMBLY") ?? "<- Click to choose"
        
        houseLabel.text = usHouseSetting
        senateLabel.text = caSenateSetting
        assemblyLabel.text = caAssemblySetting
    }
    
  
    override func viewDidLoad() {
        
        loadPrefs()
        
        super.viewDidLoad()
        
    }
    
    
    @IBAction func houseButtonTapped(sender:UIButton!) {
        println("house tapped")
        currentPicker = _us_house
        pickerView.reloadAllComponents()
        pickerViewView.hidden = false;
    }
    @IBAction func senateButtonTapped(sender:UIButton!) {
        println("senate tapped")
        currentPicker = _ca_senate
        pickerView.reloadAllComponents()
        pickerViewView.hidden = false;
    }
    @IBAction func assemblyButtonTapped(sender:UIButton!) {
        println("assembly tapped")
        currentPicker = _ca_assembly
        pickerView.reloadAllComponents()
        pickerViewView.hidden = false;
    }
    
    @IBAction func cancelButtonTapped(sender:UIButton!) {
        println("cancel")
        pickerViewView.hidden = true;
        currentRow = 0
    }
    @IBAction func doneButtonTapped(sender:UIButton!) {
        println("done")
        pickerViewView.hidden = true
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        if (currentPicker == _us_house) {
            houseLabel.text = _us_house[currentRow]
            prefs.setObject(_us_house[currentRow],forKey:"US_HOUSE")
            prefs.setObject(_us_house_emails[currentRow],forKey:"US_HOUSE_EMAIL")
        } else if (currentPicker == _ca_senate) {
            senateLabel.text = _ca_senate[currentRow]
            prefs.setObject(_ca_senate[currentRow],forKey:"CA_SENATE")
            prefs.setObject(_ca_senate_emails[currentRow],forKey:"CA_SENATE_EMAIL")
        } else if (currentPicker == _ca_assembly) {
            assemblyLabel.text = _ca_assembly[currentRow]
            prefs.setObject(_ca_assembly[currentRow],forKey:"CA_ASSEMBLY")
            prefs.setObject(_ca_assembly_emails[currentRow],forKey:"CA_ASSEMBLY_EMAIL")
        }
        prefs.synchronize()
        currentRow = 0
    }
    
    func pickerView(pickerView:UIPickerView, numberOfRowsInComponent component:NSInteger) -> Int {
        return currentPicker.count;
    }
    
    func numberOfComponentsInPickerView(pickerView:UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(pickerView:UIPickerView, didSelectRow row:Int, inComponent component:Int) {
        currentRow = row
    }
    
    
    func pickerView(pickerView:UIPickerView, titleForRow row:NSInteger, forComponent component:NSInteger) -> String {
        return currentPicker[row]
    }
    
    func pickerView(pickerView:UIPickerView, widthForComponenet component:NSInteger) -> Int {
        return 300;
    }

}