//
//  RioSubCategoryModel.swift
//  Rio
//
//  Created by Madhur Mohta on 13/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class RioSubCategoryModel: NSObject {

    var Category : String?
    var Subcategory : String?
    
    
    func initWithValue(category:String, subCategory:String)
    {
        self.Category = category
        self.Subcategory = subCategory
    }


}
