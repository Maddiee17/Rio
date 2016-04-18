//
//  RioUserProfileModel.swift
//  Rio
//
//  Created by Madhur Mohta on 09/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class RioUserProfileModel: NSObject {

    var createdDate : Int?
    var emailId : String?
    var facebookId : String?
    var googleId : AnyObject?
    var modifiedDate : Int?
    var name : String?
    var notificationId : String?
    var photoUrl : String?
    var userId : String?
    
    
    func initWithValues(createdDate:Int, email:String, fbId:String, gId: String, modifiedDate:Int, name:String, notificationId: String, photoUrl:String, userId:String)
    {
        self.createdDate = createdDate
        self.emailId = email
        self.facebookId = fbId
        self.googleId = gId
        self.modifiedDate = modifiedDate
        self.name = name
        self.notificationId = notificationId
        self.photoUrl = photoUrl
        self.userId = userId
    }
}
