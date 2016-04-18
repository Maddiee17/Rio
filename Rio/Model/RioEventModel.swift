//
//  RioEventModel.swift
//  Rio
//
//  Created by Madhur Mohta on 06/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class RioEventModel: NSObject
{
    var type : String?
    var DisciplineCode : String?
    var SessionCode : String?
    var Date : String?
    var StartTime : String?
    var EndTime : String?
    var Discipline : String?
    var Gender : String?
    var Description : String?
    var DescriptionLong : String?
    var Medal : String?
    var Demand : String?
    var VenueName : String?
    var Level : String?


    func initWithValues(type:String, DisciplineCode:String, SessionCode:String, Date:String, StartTime:String, EndTime: String, Discipline:String, Gender:String, Description:String, DescriptionLong:String, Medal:String, Demand:String, VenueName:String, Level:String)
    {
        self.type = type
        self.DisciplineCode = DisciplineCode
        self.SessionCode = SessionCode
        self.Date = Date
        self.StartTime = StartTime
        self.EndTime = EndTime
        self.Discipline = Discipline
        self.Gender = Gender
        self.Description = Description
        self.DescriptionLong = DescriptionLong
        self.Medal = Medal
        self.Demand = Demand
        self.VenueName = VenueName
        self.Level = Level
    }
}