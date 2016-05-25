//
//  RioUtilities.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit


class RioUtilities: NSObject {
    
    var isAlertAlreadyDisplayed = false
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
//        let arrayForTime = startTime?.componentsSeparatedByString(":")
//        let arrayForDates = date?.componentsSeparatedByString("-")
//        
//        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
//        let year = Int(arrayForDates![2])
//        let month = Int(arrayForDates![1])
//        let day = Int(arrayForDates![0])
//        let hour = Int(arrayForTime![0])! + 3  //UTC - 3 is Rio Time, Default notification is 1Hr before
//        let minutes = Int(arrayForTime![1])
//        
//        let dateComponents = NSDateComponents()
//        dateComponents.day = day!
//        dateComponents.month = month!
//        dateComponents.year = year!
//        dateComponents.hour = hour
//        dateComponents.minute = minutes!
//        dateComponents.second = 0
//        dateComponents.timeZone = NSTimeZone(name: "UTC")
//        let UTCDate = calender!.dateFromComponents(dateComponents)
//        let dateLocal = self.getLocalDate(UTCDate!)
//        
//        let formatter = NSDateFormatter()
//        formatter.dateStyle = .LongStyle
//        formatter.timeZone = NSTimeZone.localTimeZone()
//        let localDate = formatter.dateFromString()
//        
//        return dateLocal
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
        formatter.timeZone = NSTimeZone.init(abbreviation: "BRT")
        //formatter.locale = NSLocale.currentLocale()
        
        let finalDate = date! + " " + startTime! + ":00"
        let objDate = formatter.dateFromString(finalDate)
        
        
        return getLocalDate(objDate!)
    }
    
    
    func getLocalDate(utcDate:NSDate) -> NSDate
    {
        let timeInterval = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
//        let timeZoneObj = NSTimeZone.localTimeZone()
        let localdate = utcDate.dateByAddingTimeInterval(timeInterval)
//        let isDayLightSavingOn = timeZoneObj.isDaylightSavingTimeForDate(localdate)
//        if(isDayLightSavingOn == true)
//        {
//            let dayLightTimeInterval = timeZoneObj.daylightSavingTimeOffsetForDate(localdate)
//            timeInterval -= dayLightTimeInterval
//        }
//        localdate = utcDate.dateByAddingTimeInterval(timeInterval)
        return localdate
    }
    
    
    func getDateFromComponents(startTime:String, date:String) -> NSDate
    {
//        let date = date
//        let startTime = startTime
//        let arrayForTime = startTime.componentsSeparatedByString(":")
//        let arrayForDates = date.componentsSeparatedByString("-")
//        
//        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
//        let year = Int(arrayForDates[0])
//        let month = Int(arrayForDates[1])! - 3
//        let day = Int(arrayForDates[2])
//        let hour = Int(arrayForTime[0])!
//        let minutes = Int(arrayForTime[1])
//        
//        let dateComponents = NSDateComponents()
//        dateComponents.day = day!
//        dateComponents.month = month
//        dateComponents.year = year!
//        dateComponents.hour = hour
//        dateComponents.minute = minutes!
//        dateComponents.second = 0
//        let UTCDate = calender!.dateFromComponents(dateComponents)
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        formatter.timeZone = NSTimeZone.localTimeZone()
        //formatter.locale = NSLocale.currentLocale()
        
        let finalDate = date + " " + startTime
        let UTCDate = formatter.dateFromString(finalDate)

        
        return UTCDate!
    }
    
    
    func getAttributedString(title:String, description:String) -> NSMutableAttributedString
    {
        var toBeAppendedString : NSMutableAttributedString?
        
        let titleLabelString : NSMutableAttributedString = self.createAttributedString(title, textStyle: UIFontTextStyleFootnote, color:UIColor(hex:0xD21F69), trait: "bold")
        
        toBeAppendedString = self.createAttributedString(description, textStyle: UIFontTextStyleCaption2, color:UIColor.darkGrayColor(), trait: "")
        
        
        titleLabelString.appendAttributedString(NSAttributedString(string:"\n" + "\n"))
        titleLabelString.appendAttributedString(toBeAppendedString!)
        
        return titleLabelString
    }
    
    func createAttributedString(baseString:String, textStyle:String, color:UIColor, trait:String) -> NSMutableAttributedString {
        let baseAttrString = NSMutableAttributedString(string: baseString)
        let baseAttrRange = NSMakeRange(0, baseAttrString.length)
        var attributedFont : UIFont?
        if trait == "bold" {
            attributedFont  = UIFont.boldSystemFontOfSize(16)
        }
        else {
            attributedFont = UIFont.systemFontOfSize(15)
        }
        let fontDictionary = [NSFontAttributeName : attributedFont!, NSForegroundColorAttributeName : color]
        baseAttrString.setAttributes(fontDictionary, range: baseAttrRange)
        return baseAttrString
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
        
        return results ?? [:]
    }

    func convertDictToData(paramsDict : NSDictionary) -> NSData
    {
        var data : NSData?
        do{
            data = try NSJSONSerialization.dataWithJSONObject(paramsDict, options: NSJSONWritingOptions.PrettyPrinted)
        }
        catch{
            print("JSON error")
        }
        return data!
    }
    
    func displayAlertView(titleString: String, messageString: String) {
        
        if !isAlertAlreadyDisplayed {
            let alert: UIAlertView = UIAlertView(title: titleString, message: messageString, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            isAlertAlreadyDisplayed = true
        }
    }
    
    func getTrimmedTime(startTime:String) -> String
    {
        let rangeOfLast = Range(start: startTime.startIndex, end: startTime.endIndex.advancedBy(-3))
        return startTime[rangeOfLast]
        
    }
    
    func getTrimmedDate(date:String) -> String
    {
        let rangeOfLast = Range(start: date.startIndex.advancedBy(5), end: date.endIndex)
        return date[rangeOfLast]
        
    }
    
    func getVenueName(venue : String) -> String
    {
        let range = Range(start: venue.startIndex, end: venue.startIndex.advancedBy(4))
        let venueName = venue[range]
        if venueName == "Samb" {
            return "Sambódromo"
        }
        else if venueName == "Mara"{
            return "Maracanãzinho"
        }
        else{
            return venue
        }
    }
    
    func getDateStringFromTimeInterval(timeInterval: Int) -> (String,String) {
        let date = NSDate(timeIntervalSince1970: Double(timeInterval) / 1000)
       // let dateString = date.description
        let formatter = NSDateFormatter()
        formatter.timeZone = NSTimeZone.localTimeZone()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let dateString = formatter.stringFromDate(date)
        var componentsString = dateString.componentsSeparatedByString("T")
        let dateComponents = self.getTrimmedDate(componentsString[0])
        let timeComponemts = self.getTrimmedTime(componentsString[1])
        return (dateComponents,timeComponemts)
    }
    
    func notificationStatus() -> String
    {
        if let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        {
            if settings.types == .None
            {
                return kNo
            }
            else
            {
                return kYes
            }
        }
        
        return kNo
    }


}
