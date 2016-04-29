//
//  UpdateReminderOperation.swift
//  Rio
//
//  Created by Madhur Mohta on 29/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit

class UpdateReminderOperation: NSOperation {

    
    var manager = WSManager.sharedInstance
    var epochTS : String?
    
    init(epochTS:String){
        
        self.epochTS = epochTS
        super.init()
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    func sync(){
        
        manager.updateReminderTime(epochTS!)
    }
    
    override func cancel() {
        super.cancel()
    }

}
