//
//  CategoryRowController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 11/06/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import WatchKit

class CategoryRowController: NSObject {

    @IBOutlet var type : WKInterfaceLabel!
    @IBOutlet var image : WKInterfaceImage!

    var categoryType : String?{
        
        didSet{
            
            categoryType = categoryType!.stringByReplacingOccurrencesOfString("\n", withString: " ")
            let arc = UIImage(named: categoryType!)
            if categoryType == "Marathon swimming" {
                image.setImage(UIImage(named: "Swimming"))
            }
            else {
                image.setImage(arc)
            }
            type.setText(categoryType)

            image.setTintColor(UIColor(hex:0xD21F69))
        }
    }
}
