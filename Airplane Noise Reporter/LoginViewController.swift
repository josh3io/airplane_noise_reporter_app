//
//  LoginViewController.swift
//  Hugzer
//
//  Created by Josh Goldberg on 3/8/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    var doLogout:Bool = false
    
    var myAPI:AirplaneNoiseApi
    
    required init(coder aDecoder: NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.myAPI = appDelegate.airplaneNoiseApi
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated:Bool) {
        super.viewDidAppear(animated)
        
        let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        let loggedin:Int = prefs.integerForKey("ISLOGGEDIN")
        if (loggedin == 1) {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if (doLogout == true) {
            println("doLogout is true")
            doLogout = false
            
            let prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
            
            if let prefsUser = prefs.objectForKey("USERNAME") as? String
            {
                self.myAPI.logout(prefsUser,callback:logoutComplete)
                
                prefs.setObject("",forKey:"USERNAME")
                prefs.setObject("",forKey:"PASSWORD")
                prefs.setInteger(0,forKey:"ISLOGGEDIN")
                prefs.synchronize()
            }
        } else {
            println("doLogout is false")
            
        }
        
    }
    
    func logoutComplete(success:Bool) {
        // do nothing
    }
    
    func showSigninError() {
        println("signin failed")
        
        dispatch_async(dispatch_get_main_queue(),{
            var alert = UIAlertController(title:"Oops!",message:"Please enter a valid username and password to sign in", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title:"OK", style:UIAlertActionStyle.Default, handler:nil))
            self.presentViewController(alert, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func SignInButtonTapped(sender: UIButton!) {
        println("signin tapped")
        let username:NSString = usernameField.text
        let password:NSString = passwordField.text
        if (username.isEqualToString("") || password.isEqualToString("")) {
            showSigninError()
        } else {
            println("do login")
            self.myAPI.login(username, password: password, callback: loginSuccess)
        }
    }
    
    
    func loginSuccess(user:AirplaneNoiseUser) {
        println("loginSuccess callback")
        
        if (user.username.isEqualToString("") || user.username.isEqualToString("Anonymous")) {
            showSigninError()
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
