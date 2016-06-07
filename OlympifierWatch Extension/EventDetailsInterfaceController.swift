//
//  EventDetailsInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 08/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit
import Foundation


@available(iOS 8.2, *)
class EventDetailsInterfaceController: WKInterfaceController {

    @IBOutlet var categoryImage: WKInterfaceImage!
    @IBOutlet var eventTitle: WKInterfaceLabel!
    @IBOutlet var eventDate: WKInterfaceLabel!
    @IBOutlet var eventTime: WKInterfaceLabel!
    @IBOutlet var eventMedal: WKInterfaceLabel!
    @IBOutlet var eventVenue: WKInterfaceLabel!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
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
