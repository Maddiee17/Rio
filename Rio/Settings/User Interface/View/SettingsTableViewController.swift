//
//  IndusSettingsTableViewController.swift
//  Indus
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
    var secondAlertLabel : String?
//    var dataManager : IndusCourseDataManager! = IndusCourseDataManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftMenuButton()
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBecomeActive", name: UIApplicationWillEnterForegroundNotification, object: nil)
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
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let stringFromUserDefaultsForFirstAlert = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate)
        
        if(section == 0) {
            return 2
        }
        return 1
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section == 0 && indexPath.row == 1)
        {
            performSegue = true
            self.performSegueWithIdentifier("settingSegue", sender: self)
        }
        else if(indexPath.section == 0 && indexPath.row == 2)
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
        if(notificationStatus() == kNo)
        {
            message = "Turn on notifications in Settings to receive reminders"
        }
        else {
            message = "Turn off notifications in Settings to not receive reminders"
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
    
    func notificationStatus() -> String
    {
        if let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        {
            if settings.types == .None
            {
                return kNo
            }
            else
            {
                return kYes
            }
        }

        return kNo
    }

    func selectedValueForAlert(value:String, isFirstAlert:Bool)
    {
        if(isFirstAlert == true)
        {
            firstAlertLabel = value
            NSUserDefaults.standardUserDefaults().setObject(firstAlertLabel, forKey: kAlertFirstDate)
        }
        else{
            secondAlertLabel = value
            NSUserDefaults.standardUserDefaults().setObject(secondAlertLabel, forKey: kAlertSecondDate)
        }
        self.tableView.reloadData()

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
                cell!.detailTextLabel?.text = notificationStatus()
            case 1:
                cell!.textLabel?.text = "Alert"
                cell!.detailTextLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate) ?? kOneDayBeforeDue
                cell!.accessoryType = .DisclosureIndicator
            default:
                cell!.textLabel?.text = ""
            }
        }
        return cell!
    }

}
