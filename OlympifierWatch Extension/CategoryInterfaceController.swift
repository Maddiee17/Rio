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
    
    var categoryModel : RioCategoryModel?{
        didSet{
            
            if let model = categoryModel{
                
                
            }
        }
    }
    
    override func didAppear() {
        super.didAppear()
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            session?.sendMessage(["model":"category"], replyHandler: { (response) in
                
                print(response)
                let categoryModel = response["categoryModel"] as! [RioCategoryModel]
                print(categoryModel.count)
                }, errorHandler: { (error) in
                    print("error")
            })
            
        }
    }
    
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
