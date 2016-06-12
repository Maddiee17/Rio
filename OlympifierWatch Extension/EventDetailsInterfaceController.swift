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
    var eventDetails : NSArray?{
        
        didSet{
            self.tableView.setNumberOfRows((eventDetails?.count)!, withRowType: "EventCell")
            
            for index in 0..<tableView.numberOfRows {
                if let controller = tableView.rowControllerAtIndex(index) as? EventRowController {
                    controller.eventDict = eventDetails![index] as? NSDictionary
                }
            }
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if let type = context as? String {
            self.categoryType = type
            print(categoryType)
        }
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                session?.sendMessage(["model":"event", "categorySelected" : categoryType!], replyHandler: { (response) in
                    
                    print(response)
                    self.eventDetails = response["eventModel"] as? NSArray
                    print(self.eventDetails!)
                    }, errorHandler: { (error) in
                        print("error")
                })
                
            }
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
