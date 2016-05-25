//
//  SettingsDetailController.swift
//  Rio
//
//  Created by Madhur Mohta on 19/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

let kAlertFirstDate = "AlertFirstDate"
let kNone = "None"
let kEventStart = "Event Start"
let kSettingsDetails = "Settings Detail"

let dayValueDict = ["Event Start":"0", "1 Hour Before": "1", "2 Hours Before": "2", "3 Hours Before":"3"]
let epochValues = [0 : "0000000" , 1 : "3600000" , 2 : "7200000" , 3 : "1080000"]

protocol SettingsDetailDelegate{
    
    func selectedValueForAlert(value:String)
}

/**
 
Popoulate the setting detail view controller
 
 */


class SettingsDetailController: UITableViewController, UIGestureRecognizerDelegate {
    
    var firstAlertValue : String?
    var secondAlertValue : String?
    var checkedIndexPath : NSIndexPath?
    var delegate:SettingsDetailDelegate?

    var indexOfCheckMarkForFirstAlert : Int?
    
    var selectedIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpIndexPath()
        setUpLeftBarButton()
        
        self.tableView.backgroundColor = UIColor(hex : 0xecf0f1)

        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil) {
            self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setUpData()
        
        self.mm_drawerController.openDrawerGestureModeMask = .None
        self.mm_drawerController.closeDrawerGestureModeMask = .None
 }
    
    func setUpLeftBarButton() {
        
        let btnBackImage = UIImage(named: "ico-left-arrow")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let btnBack = UIBarButtonItem(image: btnBackImage, style: .Plain, target: self, action: #selector(SubCategoryViewController.backButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = btnBack
    }
    
    func backButtonTapped(sender:AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil && gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            return true
        }
        return false
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
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        let cellLabel = cell?.textLabel?.text!
        
            indexOfCheckMarkForFirstAlert = Int((dayValueDict as NSDictionary).valueForKey(cellLabel!)! as! String)
        
        if selectedIndexPath != nil {
            removeCheckmark(selectedIndexPath!)
        }
        
        placeCheckmark(indexPath)
        selectedIndexPath = indexPath
        delegate?.selectedValueForAlert(cellLabel!)
        rescheduleNotification()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func setUpIndexPath()
    {
        firstAlertValue = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate)
        if(firstAlertValue != nil){
            indexOfCheckMarkForFirstAlert = Int(dayValueDict[firstAlertValue!]!)
        }
        else{
            indexOfCheckMarkForFirstAlert = 0
        }
    }
    
    func setUpData()
    {
            self.title = "Alert"

        var indexPathForCell : NSIndexPath?


            if(indexOfCheckMarkForFirstAlert != 0)
            {
                 indexPathForCell = NSIndexPath(forRow: indexOfCheckMarkForFirstAlert!-1, inSection: 1)
            }
            else
            {
                indexPathForCell = NSIndexPath(forRow: indexOfCheckMarkForFirstAlert!, inSection: 0)
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
