//
//  RioSubCategoryModel.swift
//  Rio
//
//  Created by Pearson_3 on 13/02/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
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
