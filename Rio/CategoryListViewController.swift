//
//  ViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 05/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class CategoryListViewController: UIViewController,UIGestureRecognizerDelegate {
    
    @IBOutlet var timerView: CountdownTimerView!
    var dataManager = RioDatabaseInteractor()
    var categoryArrayLocal : [RioCategoryModel]?
    var eventArray : [RioEventModel]?
    var categorySelected : String?
    var eventForNotification : String?
    var indexForNotification : Int?
    
    @IBOutlet weak var categoryTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shyNavBarManager.scrollView = self.categoryTableView;
        self.shyNavBarManager.extensionView = timerView
        self.shyNavBarManager.stickyExtensionView = true
        setupLeftMenuButton()
        fetchCategoryModel()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil && gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            return false
        }
        return true
    }

    func setupLeftMenuButton() {
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(HomeViewController.leftDrawerButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = leftDrawerButton
    }
    
    func leftDrawerButtonPress(leftDrawerButtonPress: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: { _ in })
    }

    func handleNotification() {
        
        if RioRootModel.sharedInstance.isPushedFromNotification == true {
            
            let userInfoDict = RioRootModel.sharedInstance.userInfoDict
            if let category = userInfoDict!["title"] as? String {
                
                eventForNotification = category
                for (index,categoryModel) in (self.categoryArrayLocal?.enumerate())! {
                    
                    if categoryModel.type == eventForNotification {
                        indexForNotification = index
                        let indexPath = NSIndexPath(forRow: index, inSection: 0)
                        self.tableView(self.categoryTableView, didSelectRowAtIndexPath: indexPath)
                        break
                    }
                }
            }
            
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DB Fetch

    func fetchCategoryModel()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            self.dataManager.fetchCategoryFromDB{(results) -> Void in
                if(results.count > 0)
                {
                    self.categoryArrayLocal = results
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.categoryTableView.reloadData()
                        self.handleNotification()
                    })
                }
            }
        })
    }
    
    // MARK: - TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.categoryArrayLocal?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        if(categoryArrayLocal?.count > 0){
            
            let model = self.categoryArrayLocal![indexPath.row]
            var imageName : String?
            let categoryType = model.type?.stringByReplacingOccurrencesOfString("\n", withString: " ")
            if categoryType == "Marathon swimming" {
                imageName = "60x60_30"
            }
            else {
                imageName = String(format: "60x60_%d",indexPath.row + 1)
            }
            cell?.textLabel?.text = categoryType
            cell?.accessoryType = .DisclosureIndicator
            cell?.imageView?.image = UIImage(named: imageName!)
            cell?.textLabel?.textColor = UIColor.darkGrayColor()
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        
        if RioRootModel.sharedInstance.isPushedFromNotification == true {
            self.performSegueWithIdentifier("subCategorySegue", sender: self)
        }
        else{
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            categorySelected = (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!
        }
        
//        let categoryForLike = String(format: "SELECT * from Event WHERE Discipline LIKE '%%%@%%'", categorySelected)
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
//            self.dataManager.fetchEventsFromDB(categoryForLike) { (results) -> Void in
//                self.eventArray = results
//                let predicate = NSPredicate(format: "DescriptionLong CONTAINS[cd] %@", "Men's 800")
//                let newArray = (self.eventArray! as NSArray).filteredArrayUsingPredicate(predicate)
//                self.fireLocalNotification(newArray)
//                NSLog("Event array count %d",(newArray.count))
//            }
//
//        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        
        return 70
    }

    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if RioRootModel.sharedInstance.isPushedFromNotification == false
        {
            let indexPathOfSelectedRow = self.categoryTableView.indexPathForSelectedRow
            let selectedCell = self.categoryTableView.cellForRowAtIndexPath(indexPathOfSelectedRow!)
            eventForNotification = selectedCell?.textLabel?.text

        }
        let subCategoryVC = segue.destinationViewController as! SubCategoryViewController
        subCategoryVC.categorySelected = eventForNotification
        RioRootModel.sharedInstance.isPushedFromNotification = false
    }
    
    func fireLocalNotification(filteredArray:NSArray)
    {
        for model in filteredArray
        {
            let rioEventModel = (model as! RioEventModel)
            self.scheduleLocalNotification(rioEventModel)
        }
    }
    
    
    func scheduleLocalNotification(rioEventModel:RioEventModel)
    {
        
      let date = self.calculateFireDate(rioEventModel)
        
            let currentDate = NSDate()
                if(currentDate.compare(date) == NSComparisonResult.OrderedAscending)
                {
                    let alertBody = rioEventModel.Description!
                    fireLocalNotification(date,alertBody:alertBody)
                }
    }

    
    func fireLocalNotification(dueDate: NSDate, alertBody:String)
    {
        let notification = UILocalNotification()
        notification.alertBody = alertBody // text that will be displayed in the notification
        notification.fireDate = dueDate
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.category = "Olympics Scheduler"
        notification.userInfo = ["Hello Olympics": "Yada Yada"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func calculateFireDate(rioEventModel:RioEventModel) -> NSDate
    {
        let date = rioEventModel.Date
        let startTime = rioEventModel.StartTime
        let arrayForTime = startTime?.componentsSeparatedByString(":")
        let arrayForDates = date?.componentsSeparatedByString("-")
        
        let calender = NSCalendar(identifier:NSCalendarIdentifierGregorian)
        let year = Int(arrayForDates![2])
        let month = Int(arrayForDates![1])
        let day = Int(arrayForDates![0])
        let hour = Int(arrayForTime![0])! + 2
        let minutes = Int(arrayForTime![1])
        
        let dateComponents = NSDateComponents()
        dateComponents.day = day!
        dateComponents.month = month!
        dateComponents.year = year!
        dateComponents.hour = hour
        dateComponents.minute = minutes!
        dateComponents.timeZone = NSTimeZone(name: "UTC")
        let UTCDate = calender!.dateFromComponents(dateComponents)
        let dateLocal = self.getLocalDate(UTCDate!)
        
        return dateLocal
    }

    func getLocalDate(utcDate:NSDate) -> NSDate
    {
        var timeInterval = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
        let timeZoneObj = NSTimeZone.localTimeZone()
        let isDayLightSavingOn = timeZoneObj.isDaylightSavingTimeForDate(utcDate)
        if(isDayLightSavingOn == true)
        {
            let dayLightTimeInterval = timeZoneObj.daylightSavingTimeOffsetForDate(utcDate)
            timeInterval -= dayLightTimeInterval
        }
        let localdate = utcDate.dateByAddingTimeInterval(timeInterval)
        return localdate
    }
}

