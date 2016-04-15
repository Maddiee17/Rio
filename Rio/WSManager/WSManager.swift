//
//  WSManager.swift
//  Rio
//
//  Created by Pearson_3 on 10/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

var kConsumerKey: String = "8BHR6vaBJZl69Y82hA6T8t5Ai"

var kConsumerSecretKey: String = "TBKNx1I6I8x6PECYu2oMOwyPlB6NFt0EWJe76XnBXh3r41iBJQ"

var kTwitterAuthAPI: String = "https://api.twitter.com/oauth2/token"

var kTweetsAPI : String = "https://api.twitter.com/1.1/search/tweets.json?q=Olympics%2C"

let kAddReminderURL = "http://ec2-52-37-90-104.us-west-2.compute.amazonaws.com/olympics-scheduler/notifyScheduler/addReminder"
let kRequestTimeOutInterval = 30.0

class WSManager: NSObject {
    
    var notificationButtonTappedModel : RioEventModel?
    
    class var sharedInstance : WSManager{
        
        struct Singleton {
            static let instance = WSManager()
        }
        return Singleton.instance
    }
    
    func updateDeviceToken(deviceToken:String, email:String) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true

        var data : NSData?
        
        let paramsDict = ["emailId" : email, "notificationId" : deviceToken] as NSDictionary
        
        do{
            data = try NSJSONSerialization.dataWithJSONObject(paramsDict, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch{
            print("JSON error")
        }
        
        let endPointUrl : String = String(format: kBaseLoginURL, "updateNotificationDeviceId")
        let url = NSURL(string: endPointUrl)
        let urlRequest = NSMutableURLRequest(URL: url!)
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.HTTPBody = data!
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, response , error) -> Void in
            if(error == nil){
                print(response)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            }
            else {
                print("got Error",error)
            }
        }
        task.resume()
    }
    
    func getRecentTweets(lang:String, sucessBlock:((AnyObject) ->Void), errorBlock:((AnyObject) -> Void))
    {
        let request = NSMutableURLRequest(URL: NSURL(string: kTweetsAPI)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 1)
        request.HTTPMethod = "GET"
        request.setValue("Bearer " + NSUserDefaults.standardUserDefaults().stringForKey("twitterBearerToken")! , forHTTPHeaderField: "Authorization")
        
        self.performURLSessionForTaskForRequest(request, successBlock: { (responseData) -> Void in
            print(responseData)
            sucessBlock(responseData)
            }) { (responseError) -> Void in
                print(responseError)
                errorBlock(responseError)
        }
        
    }
    
    func addReminderForEvent()
    {
        let eventModel = self.notificationButtonTappedModel
        let request = NSMutableURLRequest(URL: NSURL(string: kAddReminderURL)!)
        let calendar = NSCalendar.currentCalendar()
        let date = calendar.dateByAddingUnit(.Minute, value: 2, toDate: NSDate(), options: [])
        let epochFireDate = String(format: "%.0f",(self.calculateFireDate(eventModel!).timeIntervalSince1970) * 1000)
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let paramsForCall = ["userId": userId!, "language": "en", "eventName":eventModel!.Discipline!, "eventVenue": eventModel!.VenueName!, "eventDetails":eventModel!.Description!, "scheduledDateTime":epochFireDate, "isMedalAvailable": ((eventModel!.Medal!) as NSString).boolValue] as NSDictionary
        var data : NSData?
        do{
            data = try NSJSONSerialization.dataWithJSONObject(paramsForCall, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch{
            print("JSON error")
        }
        request.HTTPBody = data!
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) -> Void in
            
            print(response)
            }) { (error) -> Void in
                print(error)
        }
        
    }
    
    
    func calculateFireDate(rioEventModel:RioEventModel) -> NSDate
    {
        let date = "15-4-2016"
        let startTime = "19:20"
        let arrayForTime = startTime.componentsSeparatedByString(":")
        let arrayForDates = date.componentsSeparatedByString("-")
        
        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let year = Int(arrayForDates[2])
        let month = Int(arrayForDates[1])
        let day = Int(arrayForDates[0])
        let hour = Int(arrayForTime[0])!
        let minutes = Int(arrayForTime[1])! + 2
        
        let dateComponents = NSDateComponents()
        dateComponents.day = day!
        dateComponents.month = month!
        dateComponents.year = year!
        dateComponents.hour = hour
        dateComponents.minute = minutes
        dateComponents.timeZone = NSTimeZone.localTimeZone()
        let UTCDate = calender!.dateFromComponents(dateComponents)
       // let dateLocal = self.getLocalDate(UTCDate!)
        
        return UTCDate!
    }
    
    func getLocalDate(utcDate:NSDate) -> NSDate
    {
        var timeInterval = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
        let timeZoneObj = NSTimeZone.localTimeZone()
        let isDayLightSavingOn = timeZoneObj.isDaylightSavingTimeForDate(utcDate)
        if(isDayLightSavingOn == true)
        {
            let dayLightTimeInterval = timeZoneObj.daylightSavingTimeOffsetForDate(utcDate)
            timeInterval -= dayLightTimeInterval
        }
        let localdate = utcDate.dateByAddingTimeInterval(timeInterval)
        return localdate
    }

    
    func verifyCredentialsAndGetAccessToken(block: (accessToken: String, error: NSError) -> Void)
    {
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: kTwitterAuthAPI)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: kRequestTimeOutInterval)
        request.HTTPMethod = "POST"
        request.setValue(("Basic " + "OEJIUjZ2YUJKWmw2OVk4MmhBNlQ4dDVBaTpUQktOeDFJNkk4eDZQRUNZdTJvTU93eVBsQjZORnQwRVdKZTc2WG5CWGgzcjQxaUJKUQ"), forHTTPHeaderField	: "Authorization")
        request.setValue("application/x-www-form-urlencoded;charset=UTF-8", forHTTPHeaderField:     "Content-Type")
        request.HTTPBody = "grant_type=client_credentials".dataUsingEncoding(NSUTF8StringEncoding)
        
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) -> Void in
            
            print(response)
            do{
                let results: NSDictionary  = try NSJSONSerialization.JSONObjectWithData(response as! NSData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(results)
                if let tokenValue = results["access_token"] as? String{
                    NSUserDefaults.standardUserDefaults().setObject(tokenValue, forKey: "twitterBearerToken")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            }
            catch{
                print("JSON error")
            }
            
            }) { (response) -> Void in
                print((response as! NSError).localizedDescription)
        }
    }
    
    func percentEscapeString(str : String) -> String {
        let baseEncodedString = str.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.whitespaceCharacterSet())
        return baseEncodedString!.stringByReplacingOccurrencesOfString(" ", withString: "+")
    }
    
    
//    func getBase64EncodedBearerToken() -> String {
//        let encodedConsumerToken =        kConsumerKey.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
//        
//        let encodedConsumerSecret = kConsumerSecretKey.stringByAddingPercentEscapesUsingEncoding(NSASCIIStringEncoding)
//        
//        //        let encodedConsumerToken: String = self.percentEscapeString(kConsumerKey)
//        //        let encodedConsumerSecret: String = self.percentEscapeString(kConsumerSecretKey)
//        
//        let concatenatedString = encodedConsumerToken! + ":" + encodedConsumerSecret!
//        let data = concatenatedString.dataUsingEncoding(NSASCIIStringEncoding, allowLossyConversion: true)
//        let final = data?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions())
//        return final!
//    }
    
    func performURLSessionForTaskForRequest(urlRequest: NSURLRequest, successBlock : ((AnyObject) -> Void), errorBlock: ((AnyObject) -> Void))
    {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, response , error) -> Void in
            if(error == nil){
                print(response)
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                successBlock(data!)
            }
            else {
                print("got Error",error)
                errorBlock(error!)
            }
        }
        task.resume()

    }
}