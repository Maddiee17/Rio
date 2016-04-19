//
//  AddReminderOperation.swift
//  Rio
//
//  Created by Guesst on 20/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class AddReminderOperation: NSOperation {

    var manager = WSManager.sharedInstance

    
    override init(){
        
        
        super.init()
        
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    
    func sync(){
        
        manager.addReminderForEvent()
        
    }

}
