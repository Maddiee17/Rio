//
//  RioUtilities.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit


let imagesMapping = ["Archery": "1", "Athletics" : "2", "Badminton" : "3", "Basketball" : "4", "Volleyball - Beach": "5", "Boxing": "6", "Canoe slalom" : "7", "Canoe sprint": "8", "Cycling BMX": "9", "Cycling mountain bike": "10", "Cycling road" : "11", "Cycling track" : "12", "Diving" : "13" , "Equestrian dressage" : "14", "Equestrian eventing" : "15", "Equestrian jumping" : "16", "Fencing" : "17", "Football" : "18", "Golf" : "19", "Gymnastics- Artistic" : "20", "Gymnastics- Rhythmic" : "21", "Handball" : "22", "Hockey" : "23", "Judo" : "24", "Modern pentathlon" : "25", "Rowing" : "26", "Rugby" : "27", "Sailing" :"28", "Shooting" : "29", "Swimming" : "30", "Synchronised swimming" : "31", "Table tennis" : "32", "Taekwondo": "33", "Tennis" :"34", "Gymnastics- Trampoline" : "35", "Triathlon" : "36", "Volleyball": "37", "Water polo" : "38", "Weightlifting" : "39", "Wrestling - Freestyle" : "40", "Wrestling - Greco- roman" : "41", "Marathon swimming" : "30"]


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
        let hour = Int(arrayForTime![0])! + 3  //UTC - 3 is Rio Time, Default notification is 1Hr before
        let minutes = Int(arrayForTime![1])
        
        let dateComponents = NSDateComponents()
        dateComponents.day = day!
        dateComponents.month = month!
        dateComponents.year = year!
        dateComponents.hour = hour
        dateComponents.minute = minutes!
        dateComponents.second = 0
        dateComponents.timeZone = NSTimeZone(name: "UTC")
        let UTCDate = calender!.dateFromComponents(dateComponents)
        let dateLocal = self.getLocalDate(UTCDate!)
        
        return dateLocal
    }
    
    
    func getLocalDate(utcDate:NSDate) -> NSDate
    {
        var timeInterval = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
        let timeZoneObj = NSTimeZone.localTimeZone()
        var localdate = utcDate.dateByAddingTimeInterval(timeInterval)
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
        let date = date
        let startTime = startTime
        let arrayForTime = startTime.componentsSeparatedByString(":")
        let arrayForDates = date.componentsSeparatedByString("-")
        
        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let year = Int(arrayForDates[0])
        let month = Int(arrayForDates[1])! - 3
        let day = Int(arrayForDates[2])
        let hour = Int(arrayForTime[0])!
        let minutes = Int(arrayForTime[1])
        
        let dateComponents = NSDateComponents()
        dateComponents.day = day!
        dateComponents.month = month
        dateComponents.year = year!
        dateComponents.hour = hour
        dateComponents.minute = minutes!
        dateComponents.second = 0
        let UTCDate = calender!.dateFromComponents(dateComponents)
        
        return UTCDate!
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
        let alert: UIAlertView = UIAlertView(title: titleString, message: messageString, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
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

}
