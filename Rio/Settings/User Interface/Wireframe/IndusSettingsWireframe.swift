//
//  IndusSettingsWireframe.swift
//  Indus
//
//  Created by Madhur Mohta on 18/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

let kIndusSettingsViewController = "IndusSettingsViewController"
/**

 Redirects  to the  setting screen

*/

class IndusSettingsWireframe: NSObject {
    
    var settingsPresenter :   IndusSettingsPresenter?
    var presentedViewController : UIViewController?


    func presentSettingsInterfaceFromViewController(view:UIViewController) {
        let newViewController = settingsViewController()
        newViewController.eventHandler = settingsPresenter
        let navigationController = UINavigationController(rootViewController: newViewController)
        view.presentViewController(navigationController, animated: true, completion: nil)
        presentedViewController = newViewController
    }
    
    func settingsViewController() ->  IndusSettingsTableViewController{
        let storyboard = UIStoryboard(name: "Setting", bundle: NSBundle.mainBundle())
        let addViewController: IndusSettingsTableViewController = storyboard.instantiateViewControllerWithIdentifier(kIndusSettingsViewController) as! IndusSettingsTableViewController
        return addViewController
    }
}
