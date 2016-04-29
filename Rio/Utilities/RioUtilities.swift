//
//  RioUtilities.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit

class RioUtilities: NSObject {
    
    class var sharedInstance : RioUtilities{
        
        struct Singleton {
            static let instance = RioUtilities()
        }
        return Singleton.instance
    }
    
    func filterSerialNoFromAddedReminders(remindersArray:NSArray) -> [String] {
        
        var remindersIndex = [String]()
        
        for (_,element) in remindersArray.enumerate() {
            
            if let elementValue = (element as! NSDictionary).objectForKey("eventId") as? String{
                remindersIndex.append(elementValue )
            }
            
        }
        
        return remindersIndex
    }
    
    func calculateFireDate(rioEventModel:RioEventModel) -> NSDate
    {
        let date = rioEventModel.Date
        let startTime = rioEventModel.StartTime
        let arrayForTime = startTime?.componentsSeparatedByString(":")
        let arrayForDates = date?.componentsSeparatedByString("-")
        
        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let year = Int(arrayForDates![2])
        let month = Int(arrayForDates![1])
        let day = Int(arrayForDates![0])
        let hour = Int(arrayForTime![0])! + 2
        let minutes = Int(arrayForTime![1])
        
        let dateComponents = NSDateComponents()
        dateComponents.day = day!
        dateComponents.month = month!
        dateComponents.year = year!
        dateComponents.hour = hour
        dateComponents.minute = minutes!
        dateComponents.timeZone = NSTimeZone(name: "UTC")
        let UTCDate = calender!.dateFromComponents(dateComponents)
        let dateLocal = self.getLocalDate(UTCDate!)
        
        return dateLocal
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

    //    func calculateFireDate(rioEventModel:RioEventModel) -> NSDate
    //    {
    //        let date = "15-4-2016"
    //        let startTime = "19:20"
    //        let arrayForTime = startTime.componentsSeparatedByString(":")
    //        let arrayForDates = date.componentsSeparatedByString("-")
    //
    //        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
    //        let year = Int(arrayForDates[2])
    //        let month = Int(arrayForDates[1])
    //        let day = Int(arrayForDates[0])
    //        let hour = Int(arrayForTime[0])!
    //        let minutes = Int(arrayForTime[1])! + 2
    //
    //        let dateComponents = NSDateComponents()
    //        dateComponents.day = day!
    //        dateComponents.month = month!
    //        dateComponents.year = year!
    //        dateComponents.hour = hour
    //        dateComponents.minute = minutes
    //        dateComponents.timeZone = NSTimeZone.localTimeZone()
    //        let UTCDate = calender!.dateFromComponents(dateComponents)
    //       // let dateLocal = self.getLocalDate(UTCDate!)
    //        
    //        return UTCDate!
    //    }
    
    func convertDataToDict(responseData : NSData) -> NSDictionary {
        
        var results: NSDictionary?
        do{
            results = try NSJSONSerialization.JSONObjectWithData(responseData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
            print(results)
           
        }
        catch{
            print("JSON error")
        }
        
        return results! ?? [:]
    }

    func displayAlertView(titleString: String, messageString: String) {
        let alert: UIAlertView = UIAlertView(title: titleString, message: messageString, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}
