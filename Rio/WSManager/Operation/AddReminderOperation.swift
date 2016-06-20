//
//  AddReminderOperation.swift
//  Rio
//
//  Created by Guesst on 20/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit

class AddReminderOperation: NSOperation {

    var evenModel : RioEventModel?
    var manager = WSManager.sharedInstance
    var operationCompletionBlock:(Void)->Void
    
    var indexPath : NSIndexPath?
    
    init(eventModel : RioEventModel, indexPath : NSIndexPath?, completionBlock : ()-> Void){
        
        
        self.evenModel = eventModel
        self.indexPath = indexPath
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
        
        manager.addReminderForEvent(self.evenModel!, indexpath: self.indexPath!,completionBlock: self.operationCompletionBlock)
        
    }
    
    override func cancel() {
        super.cancel()
    }
    

}
