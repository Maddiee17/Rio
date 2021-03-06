//
//  RioDatabaseInteractor.swift
//  Rio
//
//  Created by Madhur Mohta on 06/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class RioDatabaseInteractor: NSObject
{
    var dataBaseManager = RioDatabaseManager.sharedInstance
    
    func fetchCategoryFromDB (completionBlock : ([RioCategoryModel] -> Void))
    {
        let sqlStmt = "SELECT * from Category ORDER BY type ASC"
        var categoryArray = [RioCategoryModel]()
        
        dataBaseManager.fetchCategories(sqlStmt) { (results) -> Void in
            
            while(results.next() != false)
            {
                let model = RioCategoryModel()
                let assetCourseModel = RioResultSet().initWithResultSet(results, forModel:model)
                let assetModel = assetCourseModel as! RioCategoryModel
                categoryArray.append(assetModel)
                
            }
            completionBlock(categoryArray)
        }
    }
    
    
    func fetchSubCategoryFromDB (category: String, completionBlock : ([RioSubCategoryModel] -> Void))
    {
        let sqlStmt = "SELECT * from Subcategory where Category is ?"
        var subCategoryArray = [RioSubCategoryModel]()
        
        dataBaseManager.fetchSubCategoryForCategory(sqlStmt, category: category) { (results) -> Void in
            
            while(results.next() != false)
            {
                let model = RioSubCategoryModel()
                let assetCourseModel = RioResultSet().initWithResultSet(results, forModel:model)
                let assetModel = assetCourseModel as! RioSubCategoryModel
                subCategoryArray.append(assetModel)
                
            }
            completionBlock(subCategoryArray)
        }
    
    }

    func fetchUserProfile(completionBlock: (results :[RioUserProfileModel]) -> Void)
    {
        let sqlStmt = "SELECT * from UserProfile"

        var profileArray = [RioUserProfileModel]()
        dataBaseManager.fetchUserProfile(sqlStmt) { (results) -> Void in
            
            while(results.next() != false)
            {
                let profileModel = RioUserProfileModel()
                let localModel = RioResultSet().initWithResultSet(results, forModel: profileModel) as! RioUserProfileModel
                profileArray.append(localModel)
            }
            
            completionBlock(results: profileArray)
        }
        
    }
    
    func fetchEventsFromDB(sqlStmt:String, categorySelected : String ,completionBlock : ([RioEventModel] -> Void))
    {
        var eventArray = [RioEventModel]()
        
        dataBaseManager.fetchEventDetails(sqlStmt, eventSelected: categorySelected) { (results) -> Void in
            
            while(results.next() != false)
            {
                let eventModel = RioEventModel()
                let localModel = RioResultSet().initWithResultSet(results, forModel: eventModel) as! RioEventModel
                eventArray.append(localModel)
            }
            
            completionBlock(eventArray)
        }
    }
    
    func insertUserProfileValues(dataDict:NSDictionary)
    {
        let sqlStmt = "INSERT OR REPLACE INTO UserProfile(userId,emailId, avatar, name, googleId, facebookId, notificationId, photoUrl) VALUES (?,?,?,?,?,?,?,?)"

        dataBaseManager.insertUserProfileValues(sqlStmt, dataDict: dataDict)
    }
    
    func clearUserProfileTable()
    {
        let sqlStmt = "DELETE from UserProfile"
        dataBaseManager.clearUserProfileTable(sqlStmt)
    }
    
    func updateReminderIdInDB(reminderId:String, serialNo:String){
        
        let sqlStmt = "UPDATE Event set Notification = ? where Sno = ?"
        dataBaseManager.updateReminderIdInDB(sqlStmt, reminderId: reminderId, serialNo: serialNo)
    }

    func getReminderId(serialNo:String, successBlock :((String) -> Void)){
        
        let sqlStmt = "SELECT Notification from Event where Sno = ?"
        dataBaseManager.getReminderId(sqlStmt, sno: serialNo) { (reminderId) in
            successBlock(reminderId)
        }
    }

    func insertValuesFromModel(userProfileModel : RioUserProfileModel) {
        
        let dataDict = ["userId" : userProfileModel.userId!, "emailId" : userProfileModel.emailId!, "photoUrl" : userProfileModel.photoUrl!, "name" : userProfileModel.name!, "googleId": userProfileModel.googleId ?? "", "facebookId" : userProfileModel.facebookId!, "notificationId" : userProfileModel.notificationId!] as NSDictionary
        self.insertUserProfileValues(dataDict)

    }

}
