//
//  SignupViewController.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/8/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import UIKit

class SignupViewController : UIViewController, UIPickerViewDelegate, UITextFieldDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var password2Field: UITextField!
    @IBOutlet weak var genderField: UITextField!
    @IBOutlet weak var bdayField: UITextField!
    
    var myAPI:AirplaneNoiseApi
    
    var month:Int = 0
    var day:Int = 0
    var year:Int = 0
    var bdayPicker: UIDatePicker = UIDatePicker()
    
    var genderPicker: UIPickerView = UIPickerView()
    
    let gender = ["I am a...","Guy","Gal"]
    
    required init(coder aDecoder:NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.myAPI = appDelegate.airplaneNoiseApi
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        genderField.delegate = self
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.hidden = true
        genderPicker.showsSelectionIndicator = true
        genderField.inputView = genderPicker
        
        
        bdayField.delegate = self
        
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.year = -15
        
        let maxDate = calendar.dateByAddingComponents(components, toDate: date, options: nil)
        
        components.year = -25
        let defaultDate:NSDate = calendar.dateByAddingComponents(components, toDate: date, options: nil)!
        
        bdayPicker.maximumDate = maxDate
        bdayPicker.date = defaultDate
        bdayPicker.hidden = true
        bdayPicker.datePickerMode = UIDatePickerMode.Date
        bdayPicker.addTarget(self,action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.ValueChanged)
        bdayField.inputView = bdayPicker
        
        
    }
    
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == genderField {
            genderPicker.hidden = false
            bdayPicker.hidden = true
        } else if textField == bdayField {
            bdayPicker.hidden = false
            genderPicker.hidden = true
        } else {
            bdayPicker.hidden = true
            genderPicker.hidden = true
        }
    }
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == genderField {
            resignFirstResponder()
            genderPicker.hidden = true
            bdayPicker.hidden = true
        } else if textField == bdayField {
            resignFirstResponder()
            genderPicker.hidden = false
            bdayPicker.hidden = true
        }
    }
    
    
    func showSignupError(message:NSString) {
        println("signin failed")
        
        dispatch_async(dispatch_get_main_queue(),{
            var alert = UIAlertController(title:"Oops!",message:message as String, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return gender.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return gender[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if (row > 0) {
            genderField.text = "\(gender[row])"
            self.genderField.endEditing(true)
        }
    }
    
    func handleDatePicker(datePicker: UIDatePicker) {
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        bdayField.text = dateFormatter.stringFromDate(datePicker.date)
        
        let calendar:NSCalendar = NSCalendar.currentCalendar()
        
        year = calendar.component(.CalendarUnitYear, fromDate: datePicker.date)
        month = calendar.component(.CalendarUnitMonth, fromDate: datePicker.date)
        day = calendar.component(.CalendarUnitDay,fromDate:datePicker.date)
    }
    
    
    @IBAction func genderFieldTouch(sender: UITextField) {
        genderPicker.hidden = false
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        var username:NSString = usernameField.text
        var email:NSString = emailField.text
        var password:NSString = passwordField.text
        var password2:NSString = password2Field.text
        var gender:NSString = genderField.text
        var bday:NSString = bdayField.text
        
        if (!password.isEqualToString(password2 as String)) {
            showSignupError("Make sure your password confirmation matches")
            return
        }
        
        if (username.isEqualToString("")) {
            showSignupError("please choose a username")
            return
        }
        if (email.isEqualToString("")) {
            showSignupError("please enter your email address")
            return
        }
        
        if (gender.isEqualToString("I am a...")) {
            showSignupError("Please choose a gender")
            return
        }
        
        if (bday.isEqualToString("")) {
            showSignupError("Please enter your birthdate")
            return
        }
    
        
        self.myAPI.signup(username as String, password: password as String, email: email as String, gender: gender as String, year: (year as NSNumber).stringValue, month: (month as NSNumber).stringValue, day: (day as NSNumber).stringValue, callback: signupComplete)
        
    }
    
    func signupComplete(user:AirplaneNoiseUser) {
        println("singup callback")
        
        if (user.username.isEqualToString("") || user.username.isEqualToString("Anonymous")) {
            showSignupError("The username or email you chose is already in use")
        } else {
            var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            prefs.setObject(user.username,forKey:"USERNAME")
            prefs.setObject(user.password,forKey:"PASSWORD")
            prefs.setInteger(1,forKey:"ISLOGGEDIN")
            prefs.synchronize()
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}