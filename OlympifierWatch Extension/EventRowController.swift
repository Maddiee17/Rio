//
//  EventRowController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 12/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit

class EventRowController: NSObject {

    @IBOutlet var categoryImage: WKInterfaceImage!
    @IBOutlet var eventTitle: WKInterfaceLabel!
    @IBOutlet var eventDate: WKInterfaceLabel!
    @IBOutlet var eventTime: WKInterfaceLabel!
    @IBOutlet var eventMedal: WKInterfaceLabel!
    @IBOutlet var eventVenue: WKInterfaceLabel!
    
    var eventDict : NSDictionary?{
        
        didSet{
            eventTitle.setText(eventDict!["Description"] as? String)
            eventDate.setText(eventDict!["Date"] as? String)
            eventTime.setText(eventDict!["StartTime"] as? String)
            eventMedal.setText(eventDict!["Medal"] as? String)
            eventVenue.setText(getVenueName(eventDict!["VenueName"] as! String))
            categoryImage.setImage(UIImage(named: eventDict!["Discipline"] as! String))
            categoryImage.setTintColor(UIColor.redColor())
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

