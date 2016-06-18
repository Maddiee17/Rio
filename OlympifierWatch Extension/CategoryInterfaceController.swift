//
//  CategoryInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 08/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
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
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                session?.sendMessage(["model":"category"], replyHandler: { (response) in
                    
                    print(response)
                    self.categoryModel = response["categoryModel"] as? NSArray
                    print(self.categoryModel!)
                    }, errorHandler: { (error) in
                        print("error")
                })

//                let data = self.convertDictToData(["model":"category"])
//                session?.sendMessageData(data, replyHandler: { (responseData) in
//                    print(responseData)
//                    }, errorHandler: { (errorData) in
//                        print(errorData)
//                })
            }
        }
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let type = categoryModel![rowIndex]
        presentControllerWithName("SubCategory", context: type)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
//        self.tableView.setNumberOfRows(0, withRowType: "category")
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
