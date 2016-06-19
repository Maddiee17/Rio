//
//  CategoryInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 08/06/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

@available(iOS 8.2, *)
class CategoryInterfaceController: WKInterfaceController, WCSessionDelegate {

   
    @IBOutlet var tableView: WKInterfaceTable!
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    var categoryModel : NSArray?{
        didSet{
            self.tableView.setNumberOfRows((categoryModel?.count)!, withRowType: "category")
            
            for index in 0..<tableView.numberOfRows {
                if let controller = tableView.rowControllerAtIndex(index) as? CategoryRowController {
                    controller.categoryType = categoryModel![index] as? String
                }
            }
        }
    }
    
    override func didAppear() {
        super.didAppear()
        
            }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let type = categoryModel![rowIndex].stringByReplacingOccurrencesOfString("\n", withString: " ")
        presentControllerWithName("SubCategory", context: type)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
//        self.tableView.setNumberOfRows(0, withRowType: "category")
        
        self.categoryModel = ["Archery",
                              "Athletics",
                              "Badminton",
                              "Basketball",
                              "Boxing",
                              "Canoe slalom",
                              "Canoe sprint",
                              "Cycling BMX",
                              "Cycling mountain bike",
                              "Cycling road",
                              "Cycling track",
                              "Diving",
                              "Equestrian dressage",
                              "Equestrian eventing",
                              "Equestrian jumping",
                              "Fencing",
                              "Football",
                              "Golf",
                              "Gymnastics - Trampoline",
                              "Gymnastics - Artistic",
                              "Gymnastics - Rhythmic",
                              "Handball",
                              "Hockey",
                              "Judo",
                              "Marathon swimming",
                              "Modern pentathlon",
                              "Rowing",
                              "Rugby",
                              "Sailing",
                              "Shooting",
                              "Swimming",
                              "Synchronised swimming",
                              "Table tennis",
                              "Taekwondo",
                              "Tennis",
                              "Triathlon",
                              "Volleyball",
                              "Volleyball - Beach",
                              "Water polo",
                              "Weightlifting",
                              "Wrestling - Freestyle",
                              "Wrestling - Greco- roman"]
        
//        if categoryModel == nil{
//            if WCSession.isSupported()
//            {
//                session = WCSession.defaultSession()
//                
//                if WCSession.defaultSession().reachable {
//                    
//                    session?.sendMessage(["model":"category"], replyHandler: { (response) in
//                        
//                        print(response)
//                        self.categoryModel = response["categoryModel"] as? NSArray
//                        print(self.categoryModel!)
//                        }, errorHandler: { (error) in
//                            print("error")
//                    })
//                    
//                    //                let data = self.convertDictToData(["model":"category"])
//                    //                session?.sendMessageData(data, replyHandler: { (responseData) in
//                    //                    print(responseData)
//                    //                    }, errorHandler: { (errorData) in
//                    //                        print(errorData)
//                    //                })
//                }
//                else {
//                    
//                    let action2 = WKAlertAction(title: "Ok", style: .Destructive) {}
//                    self.presentAlertControllerWithTitle("", message: "iPhone not reachable", preferredStyle: .Alert, actions: [action2]
//                    )
//                }
//            }
//        }

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
