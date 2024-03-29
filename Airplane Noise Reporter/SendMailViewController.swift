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
    var prefs:NSUserDefaults = NSUserDefaults.standardUserDefaults()
    
    required init(coder aDecoder:NSCoder) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        self.myAPI = appDelegate.airplaneNoiseApi
        super.init(coder:aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: "SendMailViewController")
        
        var builder = GAIDictionaryBuilder.createScreenView()
        tracker.send(builder.build() as [NSObject : AnyObject])
    }
    
    override func viewDidLoad() {
        buildRepsList()
        buildDefaultBody()
        buildPlaneInfo()
        buildSignature()
        buildNameAndAddress()
        
        super.viewDidLoad()
        sendEmailButtonTapped(self)
    }
    
    func buildRepsList() -> Void {
        reps_list.text = "reps go here"
    }
    func buildDefaultBody() -> String {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        var str = ""
        if (prefs.stringForKey("BODY") != nil) {
            str = prefs.stringForKey("BODY")!
        } else {
            str = "To whom it may concern,\n\nAt \(timestamp), I was disturbed by the noise level of the flight detailed below.\n"
        }
        msg_body.text = str;
        return str;
    }
    func buildPlaneInfo() -> Void {
        let str = "ICAO identification \(thePlane!.hexIdent)\n"
            + "altitude \(thePlane!.altitude) feet\n";
        let str2 = str
            + "groundspeed \(thePlane!.groundSpeed) KTS\n"
            + "heading \(thePlane!.track) degrees)\n"
            + "latitude \(thePlane!.lat)\n"
            + "longitude \(thePlane!.lon)\n\n"
        plane_info.text = str2
    }
    
    func buildSignature() -> Void {
        let prefsSignature:String = prefs.stringForKey("SIGNATURE") ?? "Sincerely,"
        signature.text = prefsSignature
    }
    func buildNameAndAddress() -> Void {
        name_and_address.text = prefs.stringForKey("NAME_AND_ADDRESS")
    }
    
    func composeMessageFromUIElements() -> String {
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        let str = msg_body.text + "\n\n"
            + "ICAO identification \(thePlane!.hexIdent)\n"
            + "altitude \(thePlane!.altitude) feet\n";
        let str2 = str
            + "groundspeed \(thePlane!.groundSpeed) KTS\n"
            + "latitude \(thePlane!.lat)\n"
            + "longitude \(thePlane!.lon)\n\n"
        
        let str3 = str2
            + "\n\(signature.text)\n\n"
            + name_and_address.text
        
        return str3;
    }
    
    func getRepsEmailsList() -> [AnyObject] {
        var emails:[AnyObject] = [String]()
        
        emails.append("sfo.noise@flysfo.com")
        /*
        emails.append("senator@boxer.senate.gov")
        emails.append("senator@feinstein.senate.gov")
        emails.append("governor@governor.ca.gov")
        
        if (prefs.stringForKey("US_HOUSE_EMAIL") != nil) {
            emails.append(prefs.stringForKey("US_HOUSE_EMAIL")!)
        }
        if (prefs.stringForKey("CA_SENATE_EMAIL") != nil) {
            emails.append(prefs.stringForKey("CA_SENATE_EMAIL")!)
        }
        if (prefs.stringForKey("CA_ASSEMBLY_EMAIL") != nil) {
            emails.append(prefs.stringForKey("CA_ASSEMBLY_EMAIL")!)
        }
        */
        
        return emails;
    }
    
    @IBAction func sendEmailButtonTapped(sender: AnyObject) {
        let mailComposeViewController = configuredMailComposeViewController()
        mailComposeViewController.setToRecipients(getRepsEmailsList())
        mailComposeViewController.setSubject("Airplane Noise Report")
        mailComposeViewController.setMessageBody(composeMessageFromUIElements(), isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        
        
        let timestamp = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .MediumStyle, timeStyle: .ShortStyle)
        
        
        mailComposerVC.setToRecipients(self.getRepsEmailsList())
        
        println("To recipients:")
        for (email:String) in self.getRepsEmailsList() as! [String] {
            println(email)
        }
        
        mailComposerVC.setSubject("Airplane Noise Complaint")
        mailComposerVC.setMessageBody(composeMessageFromUIElements(), isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController!, didFinishWithResult result: MFMailComposeResult, error: NSError!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        
        var mailResult:String = ""
        switch result.value {
            
        case MFMailComposeResultCancelled.value:
            println("Mail Cancelled")
            mailResult="cancelled"
            break
        case MFMailComposeResultSaved.value:
            println("Mail Saved")
            mailResult="saved"
            break
        case MFMailComposeResultSent.value:
            myAPI.logComplaint(thePlane!)
            println("Mail Sent")
            mailResult="sent"
            
            break
        case MFMailComposeResultFailed.value:
            println("Mail Failed")
            mailResult="failed"
            break
        default:
            break
            
        }
        
        var tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName,value:"SendMailView")
        let event = GAIDictionaryBuilder.createEventWithCategory("SendMail", action: "mailComposeResult", label: mailResult, value: 1).build() as [NSObject:AnyObject]
        tracker.send(event)
        tracker.set(kGAIScreenName,value:nil)
        
        self.performSegueWithIdentifier("cancelSendReport", sender: self)
    }
}