//
//  IndusSettingDetailPresenter.swift
//  Indus
//
//  Created by Madhur Mohta on 26/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit
/**
 
Provide the setting detail for notification handling 
 */


class IndusSettingDetailPresenter: NSObject,IndusSettingDetailPresenterInterface {

    var settingInteractor : IndusSettingInteratorInterface?
    
    func fetchAssetModelForNotifications()
    {
        settingInteractor?.cancelAllNotifications()
        settingInteractor?.fetchAssetModel()
    }
    
    func cancelAllNotifications()
    {
        settingInteractor?.cancelAllNotifications()
    }

}
