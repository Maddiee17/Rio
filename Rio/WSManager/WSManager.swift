//
//  WSManager.swift
//  Rio
//
//  Created by Madhur Mohta on 10/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

var kConsumerKey: String = "8BHR6vaBJZl69Y82hA6T8t5Ai"

var kConsumerSecretKey: String = "TBKNx1I6I8x6PECYu2oMOwyPlB6NFt0EWJe76XnBXh3r41iBJQ"

var kTwitterAuthAPI: String = "https://api.twitter.com/oauth2/token"

var kTweetsAPI : String = "https://api.twitter.com/1.1/search/tweets.json?q=Olympics&result_type=popular&count=20"

let kAddReminderURL = "notifyScheduler/addReminder"

let kGetReminderURL = "notifyScheduler/getReminders?userId=%@"

let kRemoveReminderURL = "notifyScheduler/removeReminder?reminderId=%@"

let kUpdateReminderURL = "user/updateAdvanceNotificationTime"

let kBaseURL = "http://ec2-52-37-90-104.us-west-2.compute.amazonaws.com/olympics-scheduler/%@"

let kTopFiveImages = "image/getTopFiveImages"

let kRequestTimeOutInterval = 30.0



class WSManager: NSObject {
    
    
    var dataBaseManager = RioDatabaseInteractor()
    var notificationButtonTappedModel : RioEventModel?
    
    class var sharedInstance : WSManager{
        
        struct Singleton {
            static let instance = WSManager()
        }
        return Singleton.instance
    }
    
    func fetchImageFromURL(URL:String, successBlock:((NSData)-> Void))
    {
        let finalURL = NSURL(string: URL)
        let imageData = NSData(contentsOfURL: finalURL!)
        if imageData != nil {
            successBlock(imageData!)
        }
    }
    
    func updateDeviceToken(deviceToken:String, email:String, successBlock : ((AnyObject) -> Void), errorBlock:((AnyObject) ->Void)) {
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        
        let paramsDict = ["emailId" : email, "notificationId" : deviceToken] as NSDictionary
        let data = RioUtilities.sharedInstance.convertDictToData(paramsDict)
        
        let endPointUrl : String = String(format: kBaseLoginURL, "updateNotificationDeviceId")
        let url = NSURL(string: endPointUrl)
        let urlRequest = NSMutableURLRequest(URL: url!)
        urlRequest.HTTPMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.HTTPBody = data
        
        self.performURLSessionForTaskForRequest(urlRequest, successBlock: { (responseData) -> Void in
            print(responseData)
            successBlock(responseData)
        }) { (responseError) -> Void in
            print(responseError)
            errorBlock(responseError)
        }
    }

//        let session = NSURLSession.sharedSession()
//        let task = session.dataTaskWithRequest(urlRequest) { (data, response , error) -> Void in
//            if(error == nil){
//                print(response)
//                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
//            }
//            else {
//                print("got Error",error)
//            }
//        }
 //       task.resume()

    func getRecentTweets(lang:String, sucessBlock:((AnyObject) ->Void), errorBlock:((AnyObject) -> Void))
    {
        let request = NSMutableURLRequest(URL: NSURL(string: kTweetsAPI)!, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData, timeoutInterval: 1)
        request.HTTPMethod = "GET"
        if let twitterTokenValue = NSUserDefaults.standardUserDefaults().stringForKey("twitterBearerToken"){
            request.setValue("Bearer " + twitterTokenValue , forHTTPHeaderField: "Authorization")
            
            self.performURLSessionForTaskForRequest(request, successBlock: { (responseData) -> Void in
                print(responseData)
                sucessBlock(responseData)
            }) { (responseError) -> Void in
                print(responseError)
                errorBlock(responseError)
            }
        }
        
    }
    
    func getImagesURL()
    {
        let getImagesURL = String(format: kBaseURL, kTopFiveImages)
        let request = NSMutableURLRequest(URL: NSURL(string:getImagesURL)!)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) -> Void in
            
            let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
            let urlArray = results["imageVOs"] as! NSArray
            var imagesDataArray = [NSData]()
            for imagesDict in urlArray{
                let imageURL = (imagesDict as! NSDictionary).objectForKey("imageSelfLink") as! String
                self.fetchImageFromURL(imageURL, successBlock: { (responseData) in
                    print(responseData)
                    imagesDataArray.append(responseData)
                })
            }
            RioRootModel.sharedInstance.imagesURLArray = imagesDataArray
        }) { (error) in
            RioRootModel.sharedInstance.imagesURLArray = []
            print(error)
        }
    }
    
    func getReminders(successBlock:((AnyObject) -> Void), errorBlock:((AnyObject) -> Void))
    {
        print(NSUserDefaults.standardUserDefaults().stringForKey("userId"))
        let getReminderURL = String(format: kBaseURL, kGetReminderURL)
        let request = NSMutableURLRequest(URL: NSURL(string: String(format: getReminderURL, NSUserDefaults.standardUserDefaults().stringForKey("userId")!))!)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) -> Void in
            
            print(response)
                let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
                print(results)
                var serialNosArray : [String]?
                if let reminders = results["reminderList"] as? NSArray{
                    
                    RioRootModel.sharedInstance.favoritesArray = reminders
                    for reminderDict in reminders {
                        if let reminderIdValue = (reminderDict as! NSDictionary)["reminderId"] as? String{
                            if let serialNo = (reminderDict as! NSDictionary)["eventId"] as? String{
                                
                                self.dataBaseManager.updateReminderIdInDB(reminderIdValue, serialNo: serialNo )
                            }
                        }
                        
                    }
                    serialNosArray = RioUtilities.sharedInstance.filterSerialNoFromAddedReminders(reminders)
                    successBlock(serialNosArray!)
                }

        }) { (error) -> Void in
            print(error)
        }

        
    }
    
    
    func updateReminderTime(timestamp : String)
    {
        let updateReminderURL = String(format: kBaseURL, kUpdateReminderURL)
        var data : NSData?
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let paramsDict = ["userId" : userId!, "advanceNotificationTime" : timestamp] as NSDictionary
        data = RioUtilities.sharedInstance.convertDictToData(paramsDict)
        
        let request = NSMutableURLRequest(URL: NSURL(string: updateReminderURL)!)
        request.HTTPMethod = "POST"
        request.HTTPBody = data!
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) in
            let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
            print(results)
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName("updateNotificationSuccess", object: nil, userInfo:paramsDict as [NSObject : AnyObject])
            })
            
        }) { (error) in
            print(error)
            dispatch_async(dispatch_get_main_queue(), {
                NSNotificationCenter.defaultCenter().postNotificationName("updateNotificationError", object: nil, userInfo:paramsDict as [NSObject : AnyObject])
            })
        }
        
    }
    
    func addReminderForEvent(eventModel:RioEventModel)
    {
        let addReminderURL = String(format: kBaseURL, kAddReminderURL)
        let request = NSMutableURLRequest(URL: NSURL(string: addReminderURL)!)
        let localDateObj = RioUtilities.sharedInstance.getDateFromComponents(eventModel.StartTime!, date: eventModel.Date!)
        let epochFireDate = String(format: "%.0f",localDateObj.timeIntervalSince1970)
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let paramsDict = ["userId": userId!, "language": "en", "eventName":eventModel.Discipline!, "eventVenue": eventModel.VenueName!, "eventDetails":eventModel.Description!, "scheduledDateTime":epochFireDate, "isMedalAvailable": ((eventModel.Medal!) as NSString).boolValue, "eventId": eventModel.Sno!] as NSDictionary
        let data = RioUtilities.sharedInstance.convertDictToData(paramsDict)
        
        request.HTTPBody = data
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) -> Void in
            
            let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
            print(results)
            let reminderId = results.objectForKey("reminderId") as! String
            self.dataBaseManager.updateReminderIdInDB(reminderId, serialNo: eventModel.Sno!)
            
        }) { (error) -> Void in
            print(error)
        }
        
    }
    
    func removeReminder(reminderId:String,serialNo:String)
    {
        let rmReminderURL = String(format: kBaseURL, kRemoveReminderURL)
        let removeReminderURL = String(format: rmReminderURL, reminderId)
        let request = NSMutableURLRequest(URL: NSURL(string: removeReminderURL)!)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) in
            print(response)
            self.dataBaseManager.updateReminderIdInDB("", serialNo:serialNo)
//            dispatch_async(dispatch_get_main_queue(), {
//                NSNotificationCenter.defaultCenter().postNotificationName("refreshTable", object: nil, userInfo:nil)
//            })
        }) { (error) in
            print(error)
        }
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
            let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
            print(results)
            if let tokenValue = results["access_token"] as? String{
                NSUserDefaults.standardUserDefaults().setObject(tokenValue, forKey: "twitterBearerToken")
                NSUserDefaults.standardUserDefaults().synchronize()
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
        if Reachability.isConnectedToNetwork() {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(urlRequest) { (data, response , error) -> Void in
                if(error == nil){
                    print(response)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    successBlock(data!)
                }
                else {
                    errorBlock(error!)
                }
            }
            task.resume()
        }
        else{
            RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
        }
    }
}