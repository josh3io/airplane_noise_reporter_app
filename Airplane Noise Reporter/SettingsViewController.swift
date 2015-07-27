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
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var houseLabel: UILabel!
    @IBOutlet weak var senateLabel: UILabel!
    @IBOutlet weak var assemblyLabel: UILabel!
    
    @IBOutlet weak var pickerViewView:UIView!
    
    
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
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
    }
    @IBAction func doneButtonTapped(sender:UIButton!) {
        println("done")
        pickerViewView.hidden = true
    }
    
    func pickerView(pickerView:UIPickerView, numberOfRowsInComponent component:NSInteger) -> Int {
        return currentPicker.count;
    }
    
    func numberOfComponentsInPickerView(pickerView:UIPickerView) -> Int {
        return 1;
    }
    
    
    func pickerView(pickerView:UIPickerView, titleForRow row:NSInteger, forComponent component:NSInteger) -> String {
        return currentTitle;
    }
    
    func pickerView(pickerView:UIPickerView, widthForComponenet component:NSInteger) -> Int {
        return 300;
    }

}