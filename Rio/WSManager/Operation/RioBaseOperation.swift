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
    var syncModules : AddReminderOperation?
    
    init(addReminderOperation: AddReminderOperation){
        
        super.init()
        
        syncQueue = NSOperationQueue()
        syncQueue!.maxConcurrentOperationCount = 1
        self.syncModules = addReminderOperation
        startSync()
    }
    
    func startSync(){
        
//        for(_,element) in syncModules!.enumerate(){
        
            syncQueue!.addOperation(syncModules!)
  //      }
        
    }

    func stopSync() {
        if (syncQueue!.operations.count > 0) {
            syncQueue!.cancelAllOperations()
        }
    }

}
