//
//  RioRootModel.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit
import WatchConnectivity

class RioRootModel: NSObject, WCSessionDelegate {

    
    class var sharedInstance: RioRootModel {
        struct Singleton {
            static let instance = RioRootModel()
        }
        return Singleton.instance
    }
    
    var session : WCSession?
    
    var favoritesArray : NSArray?
    var addedReminderArray : [String]?{
        
        didSet{
            
            if WCSession.isSupported()
            {
                session = WCSession.defaultSession()
                
                if WCSession.defaultSession().reachable {
                    
                    session?.sendMessage(["model":"updatedReminderArray", "value" : addedReminderArray!], replyHandler: { (response) in
                        
                        }, errorHandler: { (error) in
                            print("error")
                    })
                }
            }
        }
    }
    var backgroundQueue = NSOperationQueue()
    var imagesURLArray = [NSData]()
    var emergencyTweetData : NSArray?
    var userInfoDict : [NSObject : AnyObject]?
//    var applicationBecameActiveBecauseOfNotification: Bool? = false
    var isPushedFromNotification = false
    var profileImageData : NSData?
    var userName : String?
    
    func appendSnoToNotificationEnabledArray(sno:String) -> [String] {
        
        if let _ =  RioRootModel.sharedInstance.addedReminderArray{
            self.addedReminderArray?.append(sno)
            return self.addedReminderArray!
        }
        else {
            self.addedReminderArray = [String]()
            self.addedReminderArray?.append(sno)
            return self.addedReminderArray!
        }
    }
    
    func removeSnoFromNotificationEnabledArray(sno:String) -> [String] {
        
        let index = self.addedReminderArray!.indexOf(sno)
        if let indexValue = index {
            self.addedReminderArray?.removeAtIndex(indexValue)
            return self.addedReminderArray!
        }
        return self.addedReminderArray!
    }

    
}
