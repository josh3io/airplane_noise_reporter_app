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
    
    var _us_house = ["District 18","District 20"]
    var _ca_senate = ["District 17","District 13","District 15"]
    var _ca_assembly = ["District 29","District 28"]
    var titles = ["US House","CA Senate","CA Assembly"]
    
    var currentPicker:Array<String>
    var currentTitle:String
    var currentRow:Int = 0
    
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
    
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func houseButtonTapped(sender:UIButton!) {
        println("house tapped")
        pickerViewView.hidden = false;
    }
    @IBAction func senateButtonTapped(sender:UIButton!) {
        println("senate tapped")
        pickerViewView.hidden = false;
    }
    @IBAction func assemblyButtonTapped(sender:UIButton!) {
        println("assembly tapped")
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
        } else if (currentPicker == _ca_senate) {
            senateLabel.text = _ca_senate[currentRow]
            prefs.setObject(_ca_senate[currentRow],forKey:"CA_SENATE")
        } else if (currentPicker == _ca_assembly) {
            assemblyLabel.text = _ca_assembly[currentRow]
            prefs.setObject(_ca_assembly[currentRow],forKey:"CA_ASSEMBLY")
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