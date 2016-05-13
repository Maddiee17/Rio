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
    var Aim : String?
    var Why : String?
    var Debut : String?
    var Top : String?
    
    func initWithValue(category:String, subCategory:String, aim:String, why:String, debut:String, top:String)
    {
        self.Category = category
        self.Subcategory = subCategory
        self.Aim = aim
        self.Why = why
        self.Top = top
        self.Debut = debut
    }

}
