//
//  IndusSettingsPresenter.swift
//  Indus
//
//  Created by Pearson_3 on 19/01/2016.
//  Copyright © 2016 Pearson. All rights reserved.
//

import UIKit
/**
 
Presenter of setting  will redirects to the view controller 
 
 */

class IndusSettingsPresenter: NSObject,IndusSettingsPresenterInterface {

    var settingsDetailWireframe : IndusSettingsDetailWireframe?
    
    func pushSettingDetailsVC(notificationDay:String, withVC:IndusSettingsTableViewController, isFirstAlert:Bool)
    {
        settingsDetailWireframe?.presentSettingsDetailsFromViewController(notificationDay, settingsVC: withVC, isFirstAlert: isFirstAlert)
    }
}

