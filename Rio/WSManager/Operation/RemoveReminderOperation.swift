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
    var operationCompletionBlock:(Void)->Void
    var index : NSIndexPath?
    
    init(reminderId : String, serialNo:String, indexpath:NSIndexPath,completionBlock : ()-> Void){
        
        self.serialNo = serialNo
        self.reminderId = reminderId
        self.index = indexpath
        self.operationCompletionBlock = completionBlock
        super.init()
        
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    func sync(){
        
        manager.removeReminder(reminderId!, serialNo: serialNo!, index: self.index!,completionBlock: self.operationCompletionBlock)
    }
    
    override func cancel() {
        super.cancel()
    }

}
