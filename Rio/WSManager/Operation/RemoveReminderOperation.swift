//
//  RemoveReminderOperation.swift
//  Rio
//
//  Created by Guesst on 22/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class RemoveReminderOperation: NSOperation {

    var reminderId : String?
    var serialNo : String?
    var manager = WSManager.sharedInstance
    
    init(reminderId : String, serialNo:String){
        
        self.serialNo = serialNo
        self.reminderId = reminderId
        super.init()
        
    }
    
    override func main() {
        
        if self.cancelled {
            return
        }
        
        sync()
    }
    
    
    func sync(){
        
        manager.removeReminder(reminderId!, serialNo: serialNo!)
    }
    
    override func cancel() {
        super.cancel()
    }

}
