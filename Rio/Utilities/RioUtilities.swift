//
//  RioUtilities.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class RioUtilities: NSObject {
    
    class var sharedInstance : RioUtilities{
        
        struct Singleton {
            static let instance = RioUtilities()
        }
        return Singleton.instance
    }
    
    func filterSerialNoFromAddedReminders(remindersArray:NSArray) -> [String] {
        
        var remindersIndex = [String]()
        
        for (_,element) in remindersArray.enumerate() {
            
            if let elementValue = (element as! NSDictionary).objectForKey("eventId"){
                remindersIndex.append(elementValue as! String)
            }
            
        }
        
        return remindersIndex
    }
}
