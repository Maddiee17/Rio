//
//  IndusSettingsDetailController.swift
//  Indus
//
//  Created by Madhur Mohta on 19/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

let kAlertFirstDate = "AlertFirstDate"
let kAlertSecondDate = "AlertSecondDate"
let kNone = "None"
let kOneDayBeforeDue = "1 Day Before Due"
let kSettingsDetails = "Settings Detail"

let dayValueDict = ["None":"0", "1 Day Before Due": "1", "2 Days Before Due": "2", "3 Days Before Due":"3", "4 Days Before Due":"4", "5 Days Before Due" : "5"]

protocol SettingsDetailDelegate{
    
    func selectedValueForAlert(value:String, isFirstAlert:Bool)
}

/**
 
Popoulate the setting detail view controller
 
 */


class IndusSettingsDetailController: UITableViewController {
    
    var firstAlertValue : String?
    var secondAlertValue : String?
    var checkedIndexPath : NSIndexPath?
    var delegate:SettingsDetailDelegate?
    var isFirstAlert : Bool?

    var indexOfCheckMarkForFirstAlert : Int?
    var indexOfCheckMarkForSecondAlert : Int?
    
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpIndexPath()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpData()
 }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }
        else {
            return 5
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let cellLabel = cell?.textLabel?.text!
        
        if(isFirstAlert == true){
            indexOfCheckMarkForFirstAlert = Int((dayValueDict as NSDictionary).valueForKey(cellLabel!)! as! String)
        }
        else {
            indexOfCheckMarkForSecondAlert = Int((dayValueDict as NSDictionary).valueForKey(cellLabel!)! as! String)
        }
        
        if selectedIndexPath != nil {
            removeCheckmark(selectedIndexPath!)
        }
        
        placeCheckmark(indexPath)
        selectedIndexPath = indexPath
        delegate?.selectedValueForAlert(cellLabel!, isFirstAlert: isFirstAlert!)
        rescheduleNotification()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setUpIndexPath()
    {
        if(isFirstAlert == true){
            firstAlertValue = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate)
            if(firstAlertValue != nil){
                indexOfCheckMarkForFirstAlert = Int(dayValueDict[firstAlertValue!]!)
            }
            else {
                indexOfCheckMarkForFirstAlert = 1
            }
        }
        else {
            secondAlertValue = NSUserDefaults.standardUserDefaults().stringForKey(kAlertSecondDate)
            
            if(secondAlertValue != nil){
                indexOfCheckMarkForSecondAlert = Int(dayValueDict[secondAlertValue!]!)
            }
            else {
                indexOfCheckMarkForSecondAlert = 0
            }
        }
    }
    
    func setUpData()
    {        
        if(isFirstAlert == true){
            self.title = "Alert"
        }
        else {
            self.title = "Second Alert"
        }

        var indexPathForCell : NSIndexPath?

        if(isFirstAlert == true){

            if(indexOfCheckMarkForFirstAlert != 0)
            {
                 indexPathForCell = NSIndexPath(forRow: indexOfCheckMarkForFirstAlert!-1, inSection: 1)
            }
            else
            {
                indexPathForCell = NSIndexPath(forRow: indexOfCheckMarkForFirstAlert!, inSection: 0)
            }
        }
        else {
            if(indexOfCheckMarkForSecondAlert != 0)
            {
                indexPathForCell = NSIndexPath(forRow: indexOfCheckMarkForSecondAlert!-1, inSection: 1)
            }
            else{
                indexPathForCell = NSIndexPath(forRow: indexOfCheckMarkForSecondAlert!, inSection: 0)
            }

        }
        
        selectedIndexPath = indexPathForCell
        placeCheckmark(selectedIndexPath!)

    }
    
    func placeCheckmark(indexPath:NSIndexPath)
    {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
    }
    
    func removeCheckmark(indexPath: NSIndexPath)
    {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        print(cell?.textLabel?.text)
        cell?.accessoryType = .None
    }

    func rescheduleNotification()
    {
        if(indexOfCheckMarkForFirstAlert != 0)
        {
           // eventHandler?.fetchAssetModelForNotifications()
        }
        else{
            //eventHandler?.cancelAllNotifications()
        }
    }
}
