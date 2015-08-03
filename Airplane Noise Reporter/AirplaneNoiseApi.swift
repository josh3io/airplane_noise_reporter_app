//
//  AirplaneNoiseApi.swift
//  Airplane Noise Reporter
//
//  Created by Josh Goldberg on 7/25/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation

struct _URL_STRINGS {
    private static var BaseUrlString:String = "http://scnoisereport.cloudapp.net:8080"
    private static var AirplaneFeedUrl:String = BaseUrlString + "/"
    private static var ApnUrlString:String = BaseUrlString + "/apn"
    private static var LoginUrlString:String = BaseUrlString + "/login"
    private static var LogoutUrlString:String = BaseUrlString + "/logout"
    private static var SignupUrlString:String = BaseUrlString + "/local-reg"
    private static var LogUrlString:String = BaseUrlString + "/log"

}

struct URLS {
    static var Base:NSURL = NSURL(string: _URL_STRINGS.BaseUrlString)!
    static var AirplaneFeed:NSURL = NSURL(string: _URL_STRINGS.AirplaneFeedUrl)!
    static var Apn:NSURL = NSURL(string: _URL_STRINGS.ApnUrlString)!
    static var Login:NSURL = NSURL(string: _URL_STRINGS.LoginUrlString)!
    static var Logout:NSURL = NSURL(string: _URL_STRINGS.LogoutUrlString)!
    static var Signup:NSURL = NSURL(string: _URL_STRINGS.SignupUrlString)!
    static var Log:NSURL = NSURL(string: _URL_STRINGS.LogUrlString)!
}

class AirplaneNoiseApi : NSObject
{
    var session:NSURLSession
    var user:AirplaneNoiseUser
    var selectedPlane:Airplane!
    var airplanes:[String:Airplane] = [String:Airplane]()
    
    override init() {
        user = AirplaneNoiseUser()
        session = NSURLSession.sharedSession()
    }
    
   
    
    func postreq(url:NSURL,formdata:NSString) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.HTTPBody = formdata.dataUsingEncoding(NSUTF8StringEncoding)
        
        //println("postreq \(url) with data \(formdata)")
        
        return request;
    }
    func getreq(url:NSURL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        //println("getreq \(url)")
        
        return request;
    }
    
    
    func signup(username:String,password:String,email:String,gender:String,year:String,month:String,day:String,callback:((AirplaneNoiseUser) -> ())) -> Void {
        
        let formdata = "username="+username+"&password="+password;
        let formdata2 = formdata+"&email="+email+"&gender="+gender+"&year="+year+"&month="+month+"&day="+day
        
        let request = postreq(URLS.Signup,formdata:formdata2)
        
        
        let task = session.dataTaskWithRequest(request,completionHandler: {data,response,error -> Void in
            // let thedata:NSString = NSString(data:data,encoding:NSUTF8StringEncoding)!
            // println("singup data "+thedata)
            if (error != nil) {
                let err:NSError = error as NSError
                println("signup error: "+err.description)
                callback(self.user)
                return
            }
            
            let json = JSON(data: data)
            
            if (json == nil || json["user"] == nil || json["user"]["username"] == nil) {
                println("signup failed")
            } else {
                self.user.username=json["user"]["username"].string!
                self.user.password=password
            }
            println("username \(self.user.username)")
            
            callback(self.user)
            return
        })
        task.resume()
    }
    
    
    func logComplaint(email:String) -> Void
    {
        let request = postreq(URLS.Log, formdata:"email="+email)
        let task = session.dataTaskWithRequest(request,completionHandler: {data,response,error -> Void in
            println("log posted")
        })
        task.resume()
    }
    
    
    func login(username:NSString,password:NSString, callback: ((AirplaneNoiseUser) -> ())) -> Void {
        let request = postreq(URLS.Login,formdata:"username=" + (username as String) + "&password=" + (password as String))
        
        
        let task = session.dataTaskWithRequest(request, completionHandler: {data,response, error -> Void in
            if (error != nil) {
                let err:NSError = error as NSError
                println("login error: "+err.description)
                callback(self.user)
                return
            }
            
            
            let json = JSON(data:data)
            
            if (json == nil || json["user"] == nil || json["user"]["username"] == nil) {
                println("login failed")
            } else {
                
                self.user.username=json["user"]["username"].string!
                self.user.password=password
            }
            println("username \(self.user.username)")
            
            callback(self.user)
            return
        })
        task.resume()
    }
    
    func logout(username:NSString,callback:((Bool) -> ())) -> Void
    {
        let request = getreq(URLS.Logout)
        
        let task = session.dataTaskWithRequest(request,completionHandler: {data,response,error -> Void in
            if (error != nil) {
                println("logout error")
                callback(false)
                return
            }
            
            self.user.username=""
            self.user.password=""
            callback(true)
        })
        task.resume()
        
    }


    func getAirplaneFeed(callback:((JSON) -> ())) -> Void {
        let request = getreq(URLS.AirplaneFeed)
        let task = session.dataTaskWithRequest(request, completionHandler: {data,response,error -> Void in
            let json = JSON(data:data)
            callback(json)
        })
        task.resume()
    }
    
    func initLocation(message:String) -> Void {
        /*
        let areq = postreq(URLS.Announce, formdata:"message="+message)
        let atask = session.dataTaskWithRequest(areq,completionHandler: {data,res,err -> Void in
            if (err == nil) {
                let request = self.getreq(URLS.LocationInit)
                let task = self.session.dataTaskWithRequest(request,completionHandler:nil)
                task.resume()
            }
        });
        atask.resume()
        */
        
    }
    func updateLocation(lat:String,lon:String,searchable:String) ->Void {
        //println("updateLocation \(user.username) lat \(lat) lon \(lon)")
        /*
        var date = NSDate()
        if (self.lastLocationUpdateTime < date.timeIntervalSince1970 - 60) {
            self.lastLocationUpdateTime = date.timeIntervalSince1970
            if (user.username != "" && user.username != "Anonymous") {
                let formdata:String = "username="+user.username+"&lat="+lat+"&lon="+lon+"&searchable="+searchable
                let request = postreq(URLS.Location, formdata: formdata)
                
                
                let task = session.dataTaskWithRequest(request,completionHandler:nil)
                
                task.resume()
            }
        }*/
    }
    
    func removeLocation() -> Void {
        /*
        let request = getreq(URLS.LocationRemove)
        let task = session.dataTaskWithRequest(request,completionHandler:nil)
        task.resume()
        */
    }
    
    func setApnDevice(device:String) -> Void {
        let request = postreq(URLS.Apn,formdata:"device="+device)
        let task = session.dataTaskWithRequest(request)
        task.resume()
    }
    

    
}