//
//  SendMailViewController.swift
//  Airplane Noise Reporter
//
//  Created by Josh Goldberg on 7/26/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class SendMailViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    var myAPI:AirplaneNoiseApi
    
    @IBOutlet weak var reps_list:UITextView!
    @IBOutlet weak var msg_body:UITextView!
    @IBOutlet weak var plane_info:UITextView!
    @IBOutlet weak var signature:UITextField!
    @IBOutlet weak var name_and_address:UITextView!
    
    var thePlane:Airplane?
    

    required init(coder aDecoder:NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        self.myAPI = appDelegate.airplaneNoiseApi
        super.init(coder:aDecoder)
    }
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
    }
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        let airplane:Airplane = myAPI.selectedPlane
        
        mailComposerVC.setToRecipients(["someone@somewhere.com"])
        mailComposerVC.setSubject("Airplane Noise Complaint")
        let str = "To whom it may concern,\n\n "
            + "One issue of great concern to me is the increased level of airplane noise in my area. \n"
            + "I am writing to you today to bring a particular incident to you attention.  \n"
            + "At \(timestamp), I was disturbed by the noise level of this flight: \n\n"
            + "ICAO identification \(airplane.hexIdent)\n"
            + "altitude \(airplane.altitude) feet\n";
        let str2 = str
            + "groundspeed \(airplane.groundSpeed) KTS\n"
            + "latitude \(airplane.lat)\n"
            + "longitude \(airplane.lon)\n\n"
            + "\n I hope this information is helpful in guiding policy decisions regarding quality of life for your constituents.\n"
            + "\nSincerely, \n"
         let str3 = str2
            + "___________\n"
            mailComposerVC.setMessageBody(str3, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        switch result.value {
            
        case MFMailComposeResultCancelled.value:
            println("Mail Cancelled")
        case MFMailComposeResultSaved.value:
            println("Mail Saved")
        case MFMailComposeResultSent.value:
            println("Mail Sent")
        case MFMailComposeResultFailed.value:
            println("Mail Failed")
        default:
            break
            
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}