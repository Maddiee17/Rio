//
//  SettingsTableViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 19/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

let kNotificationCell = "notificationCell"
let kYes = "Yes"
let kNo = "No"
let kDownloadOverCellular = "downloadOverCellular"
let kSettings = "Settings"
/**
 
It shows the Setting Tableview controller, user can define their own setting
 
 */


class SettingsTableViewController: UITableViewController,SettingsDetailDelegate {

    var performSegue = false
    var firstAlertLabel : String?
    var oldHrs : String?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftMenuButton()
        
        self.tableView.backgroundColor = UIColor(hex : 0xecf0f1)

    }

    func didBecomeActive() {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.performSegue = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.didBecomeActive), name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.resetToOldTime), name: "updateNotificationError", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SettingsTableViewController.resetToNewTime), name: "updateNotificationSuccess", object: nil)
        
        
        if let alertHrs =  NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate){
            oldHrs = alertHrs
        }
        else{
            oldHrs = "1 Hour Before"
        }
    }
    
    func resetToOldTime()
    {
        dispatch_async(dispatch_get_main_queue()) {
            self.firstAlertLabel = self.oldHrs
            self.tableView.reloadData()
        }
    }
    
    func resetToNewTime()
    {
        dispatch_async(dispatch_get_main_queue()) { 
            self.oldHrs = self.firstAlertLabel
            self.tableView.reloadData()
        }
    }

    
    func setupLeftMenuButton() {
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(HomeViewController.leftDrawerButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = leftDrawerButton
    }
    
    func leftDrawerButtonPress(leftDrawerButtonPress: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: { _ in })
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIApplicationWillEnterForegroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateNotificationSuccess", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "updateNotificationError", object: nil)

    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section == 0 && indexPath.row == 1)
        {
            performSegue = true
            self.performSegueWithIdentifier("settingSegue", sender: self)
        }
        else if(indexPath.section == 0 && indexPath.row == 0){
            showAlert()
        }
    }
    
    func showAlert()
    {
        var message : String?
        if(RioUtilities.sharedInstance.notificationStatus() == kNo)
        {
            message = "Turn on notifications in Settings to receive game reminders"
        }
        else {
            message = "Turn off notifications in Settings to not receive game reminders"
        }
        let alertController: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let closeAction: UIAlertAction = UIAlertAction(title: "Settings" , style: .Cancel) { action -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            })
        }
        let viewAction: UIAlertAction = UIAlertAction(title: "OK", style: .Default) { action -> Void in
        }
        alertController.addAction(closeAction)
        alertController.addAction(viewAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func selectedValueForAlert(value:String)
    {
        
        firstAlertLabel = value
        NSUserDefaults.standardUserDefaults().setObject(firstAlertLabel, forKey: kAlertFirstDate)
        NSUserDefaults.standardUserDefaults().synchronize()
        updateReminderTimeForUser(value)
        self.tableView.reloadData()
        
    }
    
    func updateReminderTimeForUser(timeForReminder : String)
    {
        let hoursBefore = Int(dayValueDict[timeForReminder]!)
        let epochTimestamp = epochValues[hoursBefore!]
        
        let operation = UpdateReminderOperation(epochTS: epochTimestamp!)
        RioRootModel.sharedInstance.backgroundQueue.addOperation(operation)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool
    {
        if performSegue {
            return true
        }
        return false
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if(indexPath.section == 0){
            switch(indexPath.row)
            {
            case 0:
                cell!.textLabel?.text = "Notification"
                cell!.detailTextLabel?.text = RioUtilities.sharedInstance.notificationStatus()

            case 1:
                cell!.textLabel?.text = "Alert"
                cell!.detailTextLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate) ?? kEventStart
                cell!.accessoryType = .DisclosureIndicator
            default:
                cell!.textLabel?.text = ""
            }
        }
        return cell!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "settingSegue"
        {
            let settingsDetails = segue.destinationViewController as! SettingsDetailController
            settingsDetails.delegate = self
        }
    }
    
}
