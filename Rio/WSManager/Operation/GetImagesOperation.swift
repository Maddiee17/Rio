//
//  GetImagesOperation.swift
//  Rio
//
//  Created by Madhur Mohta on 01/05/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class GetImagesOperation: NSOperation {

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
        
        manager.getImagesURL()
    }
    
    override func cancel() {
        super.cancel()
    }

}
