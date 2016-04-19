//
//  RioBaseOperation.swift
//  Rio
//
//  Created by Guesst on 20/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class RioBaseOperation: NSOperation {

    var syncQueue : NSOperationQueue?
    var syncModules : [AddReminderOperation]?
    
    class var sharedInstance: RioBaseOperation {
        struct Singleton {
            static let instance = RioBaseOperation()
        }
        
        return Singleton.instance
    }
    
    override init(){
        
        super.init()
        
        syncQueue = NSOperationQueue()
        syncQueue!.maxConcurrentOperationCount = 1
        startSync()
    }
    
    func startSync(){
        stopSync()
    }

    func stopSync() {
        if (syncQueue!.operations.count > 0) {
            syncQueue!.cancelAllOperations()
        }
    }

}
