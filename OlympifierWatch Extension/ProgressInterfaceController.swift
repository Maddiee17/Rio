//
//  ProgressInterfaceController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 19/06/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import WatchKit
import Foundation


class ProgressInterfaceController: WKInterfaceController {

    @IBOutlet var progressFor: WKInterfaceLabel!
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        if let text = context as? String {
            progressFor.setText(text)
        }

    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ProgressInterfaceController.dismissController), name: "dismissProgress", object: nil)
    }
    

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "dismissProgress", object: nil)
    }

}
