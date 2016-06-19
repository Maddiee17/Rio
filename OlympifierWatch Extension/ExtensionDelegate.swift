//
//  ExtensionDelegate.swift
//  OlympifierWatch Extension
//
//  Created by Madhur Mohta on 07/06/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import WatchKit
import WatchConnectivity

class ExtensionDelegate: NSObject, WKExtensionDelegate, WCSessionDelegate {

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
        }

    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        if  message["model"] as? String == "updatedReminderArray"{
            
            let updatedRemindersArray = message["value"] as! [String]
            WatchRootModel.sharedInstance.remindersArray = updatedRemindersArray
        }

    }
}
