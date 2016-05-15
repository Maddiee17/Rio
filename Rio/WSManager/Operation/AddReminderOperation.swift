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
    var indexPath : NSIndexPath?
    
    init(eventModel : RioEventModel, indexPath : NSIndexPath?){
        
        self.evenModel = eventModel
        self.indexPath = indexPath
        super.init()
        
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    
    func sync(){
        
        manager.addReminderForEvent(self.evenModel!, indexpath: self.indexPath!)
        
    }
    
    override func cancel() {
        super.cancel()
    }
    

}
