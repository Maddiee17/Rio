//
//  RioCategoryModel.swift
//  Rio
//
//  Created by Madhur Mohta on 06/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class RioCategoryModel: NSObject {

    var type : String?
    
    
    func initWithValue(category:String)
    {
        self.type = category
    }
}
