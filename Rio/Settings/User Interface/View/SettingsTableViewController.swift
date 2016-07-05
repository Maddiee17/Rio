//
//  SettingsTableViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 19/01/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

let kNotificationCell = "notificationCell"
let kYes = "Enabled"
let kNo = "Disabled"
let kDownloadOverCellular = "downloadOverCellular"
let kSettings = "Settings"


class SettingsTableViewController: UITableViewController,SettingsDetailDelegate {

    @IBOutlet var headerView: SettingsHeaderView!
    var performSegue = false
    var firstAlertLabel : String?
    var oldHrs : String?
    var isExpanded = false
    
    var seletedTimeInterval : String?{
        
        didSet{
            updateReminderTimeForUser(seletedTimeInterval!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLeftMenuButton()
        
        let alertValue = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate)
        
        if  alertValue == "Notification"{
            NSUserDefaults.standardUserDefaults().setObject(kEventStart, forKey: kAlertFirstDate)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        self.tableView.backgroundColor = UIColor(hex : 0xecf0f1)
        
        let data = RioRootModel.sharedInstance.profileImageData
        
        if let dataValue = data{
            self.headerView.profileImage.image = UIImage(data: dataValue)
        }
        else {
            self.headerView.profileImage.image = UIImage(named: "user")
            self.headerView.profileImage.tintColor = UIColor.darkGrayColor()
        }
        
        self.headerView.userName.text = "  Welcome, " + RioRootModel.sharedInstance.userName!
        self.tableView.tableHeaderView = self.headerView
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
        
        self.mm_drawerController.openDrawerGestureModeMask = .All
        self.mm_drawerController.closeDrawerGestureModeMask = .All

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
        leftDrawerButton.tintColor = UIColor.darkGrayColor()
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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 && !isExpanded && (notificationStatus() == kYes) {
            return 2
        }
        else if section == 0 && (notificationStatus() == kNo) {
            return 1
        }
        else if section == 0 && isExpanded{
            return 6
        }
        else{
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
    {
        if section == 0 {
            return "Notification Settings"
        }
        else {
            return "Others"
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(indexPath.section == 0 && indexPath.row == 1)
        {
            if !isExpanded {
                insertRows(indexPath)
            }
            else{
                collapseSection(indexPath)
            }
        }
        else if(indexPath.section == 0 && indexPath.row == 0){
            showAlert()
        }
        else if(indexPath.section == 1 && indexPath.row == 0){
            let creditsVC = self.storyboard?.instantiateViewControllerWithIdentifier("CreditsViewController") as! CreditsViewController
            self.navigationController?.pushViewController(creditsVC, animated: true)
        }
        else {
            
            let previousCell = self.tableView.cellForRowAtIndexPath(findIndex())
            previousCell?.backgroundColor = UIColor.whiteColor()
            
            let selectedCell = self.tableView.cellForRowAtIndexPath(indexPath)
            NSUserDefaults.standardUserDefaults().setObject(selectedCell?.textLabel?.text, forKey: kAlertFirstDate)
            NSUserDefaults.standardUserDefaults().synchronize()

            let alertCell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 1, inSection: 0))
            alertCell?.detailTextLabel?.text = selectedCell?.textLabel?.text
            collapseSection(NSIndexPath(forRow: 1, inSection: 0))
            seletedTimeInterval = (selectedCell?.textLabel?.text)!
        }
    }
    
    
    func insertRows(index: NSIndexPath) {
        isExpanded = true
        let indexPathsToInsert = getIndexPathsToInsert(index.section)
        let insertAnimation: UITableViewRowAnimation = .Automatic
        self.tableView.beginUpdates()
        self.tableView.insertRowsAtIndexPaths(indexPathsToInsert, withRowAnimation: insertAnimation)
        self.tableView.endUpdates()
    }
    
    func collapseSection(index: NSIndexPath) {
        isExpanded = false
        let indexPathsToDelete = getIndexPathsToInsert(index.section)
        let deleteAnimation: UITableViewRowAnimation = .Automatic
        self.tableView.beginUpdates()
        self.tableView.deleteRowsAtIndexPaths(indexPathsToDelete, withRowAnimation: deleteAnimation)
        self.tableView.endUpdates()
    }
    
    
    func getIndexPathsToInsert(sectionIndex: NSInteger) -> [NSIndexPath] {
        var indexPathsToInsert = [NSIndexPath]()
        
        for i in 2..<6 {
            indexPathsToInsert.append(NSIndexPath(forRow: i, inSection: 0))
        }
        return indexPathsToInsert
    }
    
    func showAlert()
    {
        var message : String?
        if(notificationStatus() == kNo)
        {
            message = "Visit Settings and enable notifications to receive game reminders"
        }
        else {
            message = "Visit Settings and disable notifications to not receive game reminders"
        }
        let alertController: UIAlertController = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let closeAction: UIAlertAction = UIAlertAction(title: "Settings" , style: .Cancel) { action -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!);
            })
        }
        let viewAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Default) { action -> Void in
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
                cell?.imageView?.image = UIImage(named: "ico-bell-selected")
                cell?.imageView?.tintColor = UIColor(hex:0xD21F69)
                cell!.textLabel?.text = "Notification"
                cell!.detailTextLabel?.text = notificationStatus()

            case 1:
                cell!.textLabel?.text = "Notification Time"
                cell?.imageView?.image = UIImage(named: "clock2")
                cell?.imageView?.tintColor = UIColor(hex:0xD21F69)
                cell!.detailTextLabel?.text = NSUserDefaults.standardUserDefaults().stringForKey(kAlertFirstDate) ?? kEventStart
                cell!.accessoryType = .DisclosureIndicator
            case 2:
                cell!.textLabel?.text = "Event Start"
                
            case 3:
                cell!.textLabel?.text = "1 Hour Before"
              
            case 4:
                cell!.textLabel?.text = "2 Hours Before"
            case 5:
                cell!.textLabel?.text = "3 Hours Before"

                
            default:
                cell!.textLabel?.text = ""
            }
        }
        else {
            switch(indexPath.row)
            {
            case 0:
                cell?.textLabel?.text = "Credits"
                cell?.accessoryType = .DisclosureIndicator
                cell?.imageView?.image = UIImage(named: "cool")
                cell?.imageView?.tintColor = UIColor(hex:0xD21F69)
                cell?.detailTextLabel?.text = ""
                
            default:
                cell!.textLabel?.text = ""

            }
        }
        
        if indexPath == findIndex() {
            cell?.accessoryType = .Checkmark
        }
        else {
            if indexPath == NSIndexPath(forRow: 0, inSection: 1) {
                cell?.accessoryType = .DisclosureIndicator
            }
            else {
                cell?.accessoryType = .None
            }
        }
        return cell!
    }
    
    func findIndex() -> NSIndexPath
    {
        let valueSelected = NSUserDefaults.standardUserDefaults().objectForKey(kAlertFirstDate) as? String
        if valueSelected != nil {
            let indexPos = Int(dayValueDict[valueSelected!]!)
            return NSIndexPath(forRow: indexPos!, inSection: 0)
        }
        else {
            return NSIndexPath(forRow: 2, inSection: 0)
        }
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "settingSegue"
        {
            let settingsDetails = segue.destinationViewController as! SettingsDetailController
            settingsDetails.delegate = self
        }
    }
    
}
