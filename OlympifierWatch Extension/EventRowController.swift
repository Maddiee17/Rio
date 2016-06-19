//
//  EventRowController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 12/06/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import WatchKit

class EventRowController: NSObject {

    @IBOutlet var categoryImage: WKInterfaceImage!
    @IBOutlet var eventTitle: WKInterfaceLabel!
    @IBOutlet var eventDate: WKInterfaceLabel!
    @IBOutlet var eventTime: WKInterfaceLabel!
    @IBOutlet var eventMedal: WKInterfaceLabel!
    @IBOutlet var eventVenue: WKInterfaceLabel!
    @IBOutlet var notificationImage: WKInterfaceImage!
    
    var notificationEnabledCells : [String]?

    var eventDict : NSDictionary?{
        
        didSet{
            eventTitle.setText(eventDict!["Description"] as? String)
            eventDate.setText(eventDict!["Date"] as? String)
            eventTime.setText(eventDict!["StartTime"] as? String)
            eventMedal.setText(eventDict!["Medal"] as? String)
            eventVenue.setText(getVenueName(eventDict!["VenueName"] as! String))
            categoryImage.setImage(UIImage(named: eventDict!["Discipline"] as! String))
            categoryImage.setTintColor(UIColor.redColor())
            
            if let notificationSno = self.notificationEnabledCells{
                
                if notificationSno.contains((eventDict?.valueForKey("Sno"))! as! String)
                {
                    notificationImage.setImage(UIImage(named: "ico-bell-selected"))
                }
                else {
                    notificationImage.setImage(UIImage(named: "ico-bell"))
                }

            }
        }
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

}


