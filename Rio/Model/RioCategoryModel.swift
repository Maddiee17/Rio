//
//  RioCategoryModel.swift
//  Rio
//
//  Created by Pearson_3 on 06/02/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class RioCategoryModel: NSObject {

    var type : String?
    
    
    func initWithValue(category:String)
    {
        self.type = category
    }
}
