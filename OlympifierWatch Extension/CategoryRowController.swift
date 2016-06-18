//
//  CategoryRowController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 11/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit

class CategoryRowController: NSObject {

    @IBOutlet var type : WKInterfaceLabel!
    @IBOutlet var image : WKInterfaceImage!

    var categoryType : String?{
        
        didSet{
            let arc = UIImage(named: categoryType!)
            
            type.setText(categoryType)
            image.setImage(arc)
            image.setTintColor(UIColor(hex:0xD21F69))
        }
    }
}
