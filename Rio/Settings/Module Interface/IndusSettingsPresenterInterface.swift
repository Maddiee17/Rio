//
//  IndusSettingsPresenterInterface.swift
//  Indus
//
//  Created by Pearson_3 on 19/01/2016.
//  Copyright © 2016 Pearson. All rights reserved.
//

import UIKit
/**
 
Protocol - Method declaration for the settings tab
 
 */

protocol IndusSettingsPresenterInterface {
    
    func pushSettingDetailsVC(notificationDay:String, withVC:IndusSettingsTableViewController, isFirstAlert:Bool)
}