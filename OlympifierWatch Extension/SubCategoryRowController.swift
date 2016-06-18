//
//  SubCategoryRowController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 18/06/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import WatchKit

let valuesArray : NSArray = ["Men's", "Women's"]

class SubCategoryRowController: NSObject {

    @IBOutlet var subCategoryType: WKInterfaceLabel!
    @IBOutlet var image: WKInterfaceImage!
    
    var index : Int?
    var type : String?{
        didSet{
            self.subCategoryType.setText(type)
//            self.image.setImage(UIImage(named: type!))
        }
    }
    
    
}
