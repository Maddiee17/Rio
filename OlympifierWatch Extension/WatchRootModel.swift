//
//  WatchRootModel.swift
//  Olympifier
//
//  Created by Madhur Mohta on 18/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit

class WatchRootModel: NSObject {

    class var sharedInstance : WatchRootModel{
        
        struct Singleton {
            static let instance = WatchRootModel()
        }
        return Singleton.instance
    }
    
    
    var remindersArray : [String]?
}
