//
//  AddReminderOperation.swift
//  Rio
//
//  Created by Guesst on 20/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class AddReminderOperation: NSOperation {

    var evenModel : RioEventModel?
    var manager = WSManager.sharedInstance
    
    init(eventModel : RioEventModel){
        
        self.evenModel = eventModel
        super.init()
        
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    
    func sync(){
        
        manager.addReminderForEvent(self.evenModel!)
        
    }
    
    override func cancel() {
        super.cancel()
    }
    

}
