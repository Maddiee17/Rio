//
//  RioRootModel.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit

class RioRootModel: NSObject {

    
    class var sharedInstance: RioRootModel {
        struct Singleton {
            static let instance = RioRootModel()
        }
        return Singleton.instance
    }
    
    var favoritesArray : NSArray?
    var addedReminderArray : [String]?
    var backgroundQueue = NSOperationQueue()    
    
    func appendSnoToNotificationEnabledArray(sno:String) -> [String] {
        
        self.addedReminderArray?.append(sno)
        return self.addedReminderArray!
    }
    
    func removeSnoFromNotificationEnabledArray(sno:String) -> [String] {
        
        let index = self.addedReminderArray!.indexOf(sno)
        self.addedReminderArray?.removeAtIndex(index!)
        return self.addedReminderArray!
    }

    
}
