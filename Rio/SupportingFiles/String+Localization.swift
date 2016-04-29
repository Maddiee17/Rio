//
//  String+Localization.swift
//  Indus
//
//  Created by Madhur Mohta on 31/08/2015.
//  Copyright © 2015 Madhur. All rights reserved.
//

import Foundation


extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}