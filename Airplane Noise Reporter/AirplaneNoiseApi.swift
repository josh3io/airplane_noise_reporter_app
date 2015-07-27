//
//  AirplaneNoiseApi.swift
//  Airplane Noise Reporter
//
//  Created by Josh Goldberg on 7/25/15.
//  Copyright (c) 2015 Josh Goldberg. All rights reserved.
//

import Foundation

struct _URL_STRINGS {
    private static var BaseUrlString:NSString = "http://192.168.1.125:8441"
    private static var AirplaneFeedUrl:NSString = BaseUrlString + "/"
    private static var ApnUrlString:NSString = BaseUrlString + "/apn"
    private static var LoginUrlString:NSString = BaseUrlString + "/login"
    private static var LogoutUrlString:NSString = BaseUrlString + "/logout"
    private static var SignupUrlString:NSString = BaseUrlString + "/local-reg"

}

struct URLS {
    static var Base:NSURL = NSURL(string: _URL_STRINGS.BaseUrlString)!
    static var AirplaneFeed:NSURL = NSURL(string: _URL_STRINGS.AirplaneFeedUrl)!
    static var Apn:NSURL = NSURL(string: _URL_STRINGS.ApnUrlString)!
    static var Login:NSURL = NSURL(string: _URL_STRINGS.LoginUrlString)!
    static var Logout:NSURL = NSURL(string: _URL_STRINGS.LogoutUrlString)!
    static var Signup:NSURL = NSURL(string: _URL_STRINGS.SignupUrlString)!
}

class AirplaneNoiseApi : NSObject
{
    var session:NSURLSession
    var user:AirplaneNoiseUser
    
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
        
        println("postreq \(url) with data \(formdata)")
        
        return request;
    }
    func getreq(url:NSURL) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        println("getreq \(url)")
        
        return request;
    }
    
    
    func signup(username:NSString,password:NSString,email:NSString,gender:NSString,year:NSString,month:NSString,day:NSString,callback:((AirplaneNoiseUser) -> ())) -> Void {
        
        let formdata = "username="+username+"&password="+password+"&email="+email+"&gender="+gender+"&year="+year+"&month="+month+"&day="+day
        
        let request = postreq(URLS.Signup,formdata:formdata)
        
        
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
                self.user.setUsername(json["user"]["username"].string!)
                self.user.setPassword(password)
            }
            println("username "+self.user.username)
            
            callback(self.user)
            return
        })
        task.resume()
    }
    
    func login(username:NSString,password:NSString, callback: ((AirplaneNoiseUser) -> ())) -> Void {
        let request = postreq(URLS.Login,formdata:"username=" + username + "&password=" + password)
        
        
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
                
                self.user.setUsername(json["user"]["username"].string!)
                self.user.setPassword(password)
            }
            println("username "+self.user.username)
            
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
            
            self.user.setUsername("")
            self.user.setPassword("")
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