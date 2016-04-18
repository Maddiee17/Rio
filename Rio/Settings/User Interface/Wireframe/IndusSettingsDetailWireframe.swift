//
//  IndusSettingsDetailWireframe.swift
//  Indus
//
//  Created by Madhur Mohta on 19/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

let kIndusSettingsDetailViewController = "SettingsDetailViewController"
/**
 
Redirects  to the  detail setting screen
 
 */


class IndusSettingsDetailWireframe: NSObject {
    
    var settingsDetailPresenter :  IndusSettingDetailPresenter?


    func presentSettingsDetailsFromViewController(notificationDetail:String, settingsVC:IndusSettingsTableViewController, isFirstAlert:Bool) {
        let newViewController = settingsDetailViewController()
        newViewController.isFirstAlert = isFirstAlert
        newViewController.delegate = settingsVC
        newViewController.eventHandler = settingsDetailPresenter
        settingsVC.navigationController?.pushViewController(newViewController, animated: true)
    }
    
    func settingsDetailViewController() ->  IndusSettingsDetailController{
        let storyboard = UIStoryboard(name: "Setting", bundle: NSBundle.mainBundle())
        let addViewController: IndusSettingsDetailController = storyboard.instantiateViewControllerWithIdentifier(kIndusSettingsDetailViewController) as! IndusSettingsDetailController
        return addViewController
    }
}
