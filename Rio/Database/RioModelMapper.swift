//
//  RioModelMapper.swift
//  Rio
//
//  Created by Guesst on 24/04/2016.
//  Copyright © 2016 Madhur. All rights reserved.
//

import UIKit

class RioModelMapper: NSObject {

    override init() {
        //This must be called before you initialize the class
        super.init()
    }
    
    func initWithPreferredDict(results: NSDictionary, forModel:NSObject) -> NSObject{
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        
        let currentClass: AnyClass = forModel.classForCoder;
        let properties = class_copyPropertyList(currentClass, &count);
        
        
        // iterate each objc_property_t struct
        for var i: UInt32 = 0; i < count; i++ {
            let property = properties[Int(i)];
            
            // retrieve the property name by calling property_getName function
            let columnname = property_getName(property);
            
            // covert the c string into a Swift string
            let name = String.fromCString(columnname);
            
            if let columnValue=results.objectForKey(name!){
                forModel.setValue(columnValue ,forKey:name!);
            }
            
        }
        
        // release objc_property_t structs
        free(properties)
        
        return forModel
    }

    
}
