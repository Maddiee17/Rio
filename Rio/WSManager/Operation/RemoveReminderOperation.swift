//
//  RemoveReminderOperation.swift
//  Rio
//
//  Created by Guesst on 22/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit

class RemoveReminderOperation: NSOperation {

    var reminderId : String?
    var serialNo : String?
    var manager = WSManager.sharedInstance
    var index : NSIndexPath?
    
    init(reminderId : String, serialNo:String, indexpath:NSIndexPath){
        
        self.serialNo = serialNo
        self.reminderId = reminderId
        self.index = indexpath
        super.init()
        
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    func sync(){
        
        manager.removeReminder(reminderId!, serialNo: serialNo!, index: self.index!)
    }
    
    override func cancel() {
        super.cancel()
    }

}
