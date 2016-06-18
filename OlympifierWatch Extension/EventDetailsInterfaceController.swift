//
//  EventDetailsInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 08/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

@available(iOS 8.2, *)
class EventDetailsInterfaceController: WKInterfaceController, WCSessionDelegate {


    @IBOutlet var tableView: WKInterfaceTable!
    var session : WCSession?
    var categoryType : String?
    let kBaseURL = "http://ec2-52-37-90-104.us-west-2.compute.amazonaws.com/olympics-scheduler/%@"
    let kAddReminderURL = "notifyScheduler/addReminder"
    let kRemoveReminderURL = "notifyScheduler/removeReminder?reminderId=%@"
    var subCategorySelected : String?
    var notificationEnabledCells = [String]()
    var eventDetails : NSArray?{
        
        didSet{
            self.tableView.setNumberOfRows((eventDetails?.count)!, withRowType: "EventCell")
            
            for index in 0..<tableView.numberOfRows {
                if let controller = tableView.rowControllerAtIndex(index) as? EventRowController {
                    controller.notificationEnabledCells = self.notificationEnabledCells
                    controller.eventDict = eventDetails![index] as? NSDictionary
                }
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        findAddedReminders()

        if let eventDetailsValues = context as? NSArray {
            self.eventDetails = eventDetailsValues
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int)
    {
        var titleOfAlert : String?
        var messageOfAlert : String?
        
        var action1 : WKAlertAction?
        
        let h0 = {
            
            self.addReminderForEvent((self.eventDetails![rowIndex] as? NSDictionary)!, indexpath: rowIndex)
        }
        
        let h1 = {
            
            let sno = (self.eventDetails![rowIndex] as! NSDictionary).valueForKey("Sno") as! String
            let reminderId = (self.eventDetails![rowIndex] as! NSDictionary).valueForKey("reminderId") as! String
            self.removeReminder(reminderId, serialNo: sno)
            
        }
        
        if notificationEnabledCells.contains(((self.eventDetails![rowIndex] as! NSDictionary).valueForKey("Sno"))! as! String)
        {
            titleOfAlert = "Remove Reminder"
            messageOfAlert = "Tap OK to removed a reminder for the event"
            action1 = WKAlertAction(title: "Remove", style: .Default, handler: h1)
        }
        else {
            titleOfAlert = "Add Reminder"
            messageOfAlert = "Tap OK to add a reminder for the event"
            action1 = WKAlertAction(title: "Add", style: .Default, handler: h0)
        }
        
        
        
        let action2 = WKAlertAction(title: "Cancel", style: .Destructive) {}
        
        self.presentAlertControllerWithTitle(titleOfAlert, message: messageOfAlert, preferredStyle: .Alert, actions: [action1!, action2]
        )
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
            let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
            print(results)
            if let resultsValue = results.objectForKey("response"){
                if((resultsValue.valueForKey("statusCode")) as! NSNumber == 200){
                    
                    let index = self.notificationEnabledCells.indexOf(serialNo)
                    self.notificationEnabledCells.removeAtIndex(index!)
                    let indexInGlobalArray = WatchRootModel.sharedInstance.remindersArray!.indexOf(serialNo)
                    WatchRootModel.sharedInstance.remindersArray?.removeAtIndex(indexInGlobalArray!)
                    self.removeDataInIphone(serialNo)
                    print(resultsValue)
                    for index in 0..<self.tableView.numberOfRows {
                        if let controller = self.tableView.rowControllerAtIndex(index) as? EventRowController {
                            controller.notificationEnabledCells = self.notificationEnabledCells
                            controller.eventDict = self.eventDetails![index] as? NSDictionary
                        }
                    }
                }
            }
            
        }) { (error) in
            print(error)
        }
    }

    
    func addReminderForEvent(eventModel:NSDictionary, indexpath:Int)
    {
        let addReminderURL = String(format: kBaseURL, kAddReminderURL)
        let request = NSMutableURLRequest(URL: NSURL(string: addReminderURL)!)
        let localDateObj = RioUtilities.sharedInstance.getDateFromComponents(eventModel.valueForKey("StartTime") as! String, date: eventModel.valueForKey("Date") as! String)
        let epochFireDate = String(format: "%.0f",localDateObj.timeIntervalSince1970 * 1000)
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let paramsDict = ["userId": userId, "language": "en", "eventName": eventModel.valueForKey("Discipline") as! String, "eventVenue": eventModel.valueForKey("VenueName") as! String!, "eventDetails":eventModel.valueForKey("Description") as! String, "scheduledDateTime":epochFireDate, "isMedalAvailable": (eventModel.valueForKey("Medal") as! NSString).boolValue , "eventId" : eventModel.valueForKey("Sno") as! String] as NSDictionary
        
        
        
        let data = RioUtilities.sharedInstance.convertDictToData(paramsDict)
        
        request.HTTPBody = data
        request.HTTPMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        self.performURLSessionForTaskForRequest(request, successBlock: { (response) -> Void in
            
            let results: NSDictionary = RioUtilities.sharedInstance.convertDataToDict(response as! NSData)
            print(results)
            if let resultsValue = results.objectForKey("response"){
                if((resultsValue.valueForKey("statusCode")) as! NSNumber == 200){
//                    let reminderId = results.objectForKey("reminderId") as! String
                    let serialNo = results.objectForKey("eventId") as? String
                    self.notificationEnabledCells.append(serialNo!)
                    WatchRootModel.sharedInstance.remindersArray?.append(serialNo!)
                    self.addDataInIphone(results)
                    dispatch_async(dispatch_get_main_queue(), { 
                        for index in 0..<self.tableView.numberOfRows {
                            if let controller = self.tableView.rowControllerAtIndex(index) as? EventRowController {
                                controller.notificationEnabledCells = self.notificationEnabledCells
                                controller.eventDict = self.eventDetails![index] as? NSDictionary
                            }
                        }                    })
                }}}) { (error) -> Void in
            print(error)
        }
        
    }
    
    func addDataInIphone(results:NSDictionary)
    {
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                let reminderId = results.objectForKey("reminderId") as! String
                let serialNo = results.objectForKey("eventId") as! String

                session?.sendMessage(["model":"updateReminderId", "Sno" : serialNo, "reminderId" : reminderId], replyHandler: { (response) in
                    
                    
                    
                    }, errorHandler: { (error) in
                        print("error")
                })
                
            }
        }
        
    }
    
    func removeDataInIphone(eventId : String)
    {
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                
                session?.sendMessage(["model":"removeReminderId", "Sno" : eventId], replyHandler: { (response) in
                    
                    
                    }, errorHandler: { (error) in
                        print("error")
                })
                
            }
        }
        
    }
    
    func performURLSessionForTaskForRequest(urlRequest: NSURLRequest, successBlock : ((AnyObject) -> Void), errorBlock: ((AnyObject) -> Void))
    {
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) { (data, response , error) -> Void in
            if(error == nil){
                print(response)
                if let responseData = data{
                    successBlock(responseData)
                }
            }
            else {
                errorBlock(error!)
            }
        }
        task.resume()
    }
    
    func findAddedReminders()
    {
        if let remindersArray =  WatchRootModel.sharedInstance.remindersArray{
            self.notificationEnabledCells = remindersArray
        }
    }
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
