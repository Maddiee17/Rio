//
//  IndusSettingsInteractor.swift
//  Indus
//
//  Created by Pearson_2 on 1/25/16.
//  Copyright © 2016 Pearson. All rights reserved.
//

import Foundation
/**
 
 Provide the Settings Interactor  for the notification center
 
 */

class IndusSettingsInteractor: NSObject, IndusSettingInteratorInterface {
    

    func fetchAssetModel()
    {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
//            
//            self.dataManager.getDownloadedCoursesAssetModel{(results) -> Void in
//                if(results.count > 0)
//                {
//                    for assetModel in results{
//                        IndusUtilities.sharedInstance.scheduleLocalNotification(assetModel)
//                    }
//                }
//            }
//        })
    }
    
    func cancelAllNotifications()
    {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}