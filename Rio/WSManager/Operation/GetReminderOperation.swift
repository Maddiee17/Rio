//
//  GetReminderOperation.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class GetReminderOperation: NSOperation {

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
        
        manager.getReminders({ (response) in
            
            RioRootModel.sharedInstance.addedReminderArray = response as? [String]
            
            }) { (error) in
                print("got get reminder error")
        }
    }
    
    override func cancel() {
        super.cancel()
    }

}
