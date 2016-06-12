//
//  SplashInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 08/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SplashInterfaceController: WKInterfaceController, WCSessionDelegate {

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }
    
    var userProfileModel : NSArray?

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if WCSession.isSupported()
        {
            session = WCSession.defaultSession()
            
            if WCSession.defaultSession().reachable {
                
                session?.sendMessage(["model":"user"], replyHandler: { (response) in
                    
                    print(response)
                    self.userProfileModel = response["userProfileModel"] as? NSArray
                    print(self.userProfileModel!)
                    if self.userProfileModel?.count > 0{
                        dispatch_async(dispatch_get_main_queue(), {
                            self.performSelector(#selector(SplashInterfaceController.presentCategories
                                ), withObject: nil, afterDelay: 1.0)
                        })
                    }
                    else {
                        print("Please login In on the iPhone")
                    }

                    }, errorHandler: { (error) in
                        print("error")
                })
                
            }
        }

    }

    override func didAppear() {
        super.didAppear()
        session = WCSession.defaultSession()
        
    }
    
    func presentCategories()
    {
        self.presentControllerWithName("Category", context: self)
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
        //recieving message from iphone
        
        NSLog("This was called")        
    }
}