//
//  RioOrdinalInt.swift
//  Rio
//
//  Created by Madhur Mohta on 10/2/16.
//  Copyright © 2016 Maddiee. All rights reserved.
//

import Foundation


extension Int {
    var ordinal: String {
        get {
            var suffix = "th"
            switch self % 10 {
            case 1:
                suffix = "st"
            case 2:
                suffix = "nd"
            case 3:
                suffix = "rd"
            default: ()
            }
            if 10 < (self % 100) && (self % 100) < 20 {
                suffix = "th"
            }
            return String(self) + suffix
        }
    }
}