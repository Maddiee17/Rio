//
//  EventDetailsTableViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 12/03/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UIViewController,EventCellDelegate, UIPopoverPresentationControllerDelegate {
    
    var eventsFilteredArray = []
    var selectedEvent : String?
    var frameForButton : CGRect?
    var cellView : EventCell?
    var notificationButtonTappedCellModel : RioEventModel?
    var notificationEnabledCells = [String]()
    var popoverController : UIViewController?
    var datesArray = [String]()
    var splittedDict = Dictionary<String , Array<RioEventModel>>()
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLeftBarButton()
        findAddedReminders()
        
        tableView.sectionHeaderHeight = 5.0;
        tableView.sectionFooterHeight = 5.0;
        
        self.title = "Event Details"
        replaceWithLocalDate()
        sortDataBasedOnDate()
        setupObservers()
    }
    
    func setupObservers()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EventDetailsTableViewController.reloadData(_:)), name: "refreshTable", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EventDetailsTableViewController.showErrorToast(_:)), name: "dontRefreshTable", object: nil)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EventDetailsTableViewController.reminderAddedFailed), name: "reminderAddedFailure", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(EventDetailsTableViewController.reminderRemoveFailed), name: "removeReminderFailure", object: nil)

    }
    
    func replaceWithLocalDate()
    {
        for model in self.eventsFilteredArray
        {
            let localDateNTime = RioUtilities.sharedInstance.calculateFireDate(model as! RioEventModel).description
            (model as! RioEventModel).Date = localDateNTime.componentsSeparatedByString(" ")[0]
            (model as! RioEventModel).StartTime = localDateNTime.componentsSeparatedByString(" ")[1]
            (model as! RioEventModel).DescriptionLong = self.filterDescription(model.DescriptionLong!!)
        }
    }
    
    func setUpLeftBarButton() {
        
        let btnBackImage = UIImage(named: "ico-left-arrow")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let btnBack = UIBarButtonItem(image: btnBackImage, style: .Plain, target: self, action: #selector(EventDetailsTableViewController.backButtonTapped(_:)))
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "refreshTable", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "dontRefreshTable", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reminderAddedFailure", object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "removeReminderFailure", object: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return self.splittedDict.keys.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let key = self.datesArray[section]
        return (self.splittedDict[key]?.count) ?? 0
    }
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
//    {
//        let label = UILabel(frame: CGRectMake(15,10,100,40))
//        label.text = self.datesArray[section]
//        return label
//    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 50
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
    {
        let date = self.datesArray[section].componentsSeparatedByString("-")
        let finalString =  (Int(date[2])?.ordinal)! + " August"
        return finalString
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventCell
        
        let key = self.datesArray[indexPath.section]
        let localObj = self.splittedDict[key]
        cell.initWithEventObject(localObj![indexPath.row], notificationEnabledCell: self.notificationEnabledCells, selectedEvent: self.selectedEvent!)
        cell.delegate = self
        return cell
    }
    
    func findAddedReminders()
    {
        if let remidersArray =  RioRootModel.sharedInstance.addedReminderArray{
            self.notificationEnabledCells = remidersArray
        }
    }
    
    func notificationButtonTapped(forCell:EventCell)
    {
        cellView = forCell
        frameForButton = forCell.notificationButton.frame
        //        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        //        let popVC = storyBoard.instantiateViewControllerWithIdentifier("popover")
        //        popVC.modalPresentationStyle = .Popover
        //        self.presentViewController(popVC, animated: true, completion: nil)
        let indexPath = self.tableView.indexPathForCell(forCell)
        let sectionTitle = self.datesArray[(indexPath?.section)!]
        let modelArray = self.splittedDict[sectionTitle]
        notificationButtonTappedCellModel = modelArray![(indexPath?.row)!]
        WSManager.sharedInstance.notificationButtonTappedModel = notificationButtonTappedCellModel!
        self.performSegueWithIdentifier("popoverSegue", sender: self)
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func reloadData(notification:NSNotification)
    {
        let cellView = (notification.userInfo! as NSDictionary).objectForKey("cell") as! EventCell
        let cellTag = (notification.userInfo! as NSDictionary).objectForKey("type") as! String
        let indexPathOfCell = self.tableView.indexPathForCell(cellView)
        let sectionTitle = self.datesArray[(indexPathOfCell?.section)!]
        let modelArray = self.splittedDict[sectionTitle]

        let eventObj = modelArray![(indexPathOfCell?.row)!]
        if cellTag == "1" {
            self.notificationEnabledCells = RioRootModel.sharedInstance.appendSnoToNotificationEnabledArray(eventObj.Sno!)
        }
        else{
            self.notificationEnabledCells = RioRootModel.sharedInstance.removeSnoFromNotificationEnabledArray(eventObj.Sno!)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPathOfCell!], withRowAnimation: .Automatic)
        self.popoverController?.dismissViewControllerAnimated(true, completion: nil)
        //showSuccessToast(cellTag)
    }
    
    func reminderAddedFailed()
    {
        cellView?.notificationButton.setImage(UIImage(named: "ico-bell"), forState: .Normal)
        let userInfoDict = ["cell":self.cellView as! AnyObject, "type": "2"]
        NSNotificationCenter.defaultCenter().postNotificationName("dontRefreshTable", object: nil, userInfo:userInfoDict)
    }
    
    func reminderRemoveFailed()
    {
        cellView?.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
        let userInfoDict = ["cell":self.cellView as! AnyObject, "type": "1"]
        NSNotificationCenter.defaultCenter().postNotificationName("dontRefreshTable", object: nil, userInfo:userInfoDict)
    }

    func showErrorToast(notification:NSNotification)
    {
        self.reloadData(notification)
        self.view.makeToast("Please try again!!")
    }
    
    func showSuccessToast(tag:String)
    {
        if tag == "1" {
            self.view.makeToast("Reminder added successfully!!")
        }
        else{
            self.view.makeToast("Reminder removed!!")
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue"
        {
            self.popoverController = segue.destinationViewController
            let popoverPresentationController = segue.destinationViewController.popoverPresentationController
            popoverPresentationController!.sourceView = self.cellView
            popoverPresentationController!.sourceRect = self.frameForButton!
            popoverPresentationController?.delegate = self
            
        }
    }
    
    func sortDataBasedOnDate()
    {
        for eventModel in self.eventsFilteredArray
        {
            let localObj = eventModel as! RioEventModel
            print(localObj.Date!)
            if self.datesArray.contains((eventModel as! RioEventModel).Date!) == false {
                self.datesArray.append((eventModel.Date)!!)
            }
        }
        for date in self.datesArray {
            let predicate = NSPredicate(format: "Date = %@", date)
            let valuesArray = self.eventsFilteredArray.filteredArrayUsingPredicate(predicate) as! [RioEventModel]
            print(valuesArray)
            splittedDict.updateValue(valuesArray, forKey: date)
        }
        print(self.datesArray)
    }
    
    func filterDescription(actualString:String) -> String{
        
        var croppedString = ""
        let array = actualString.componentsSeparatedByString("|")
        var i = 0
        for (i = 0; i<array.count; i += 1) {
            
            //            if array[i].containsString("victory") || array[i].characters.count <= 8 {
            //                continue
            //            }
            if(array[i].containsString(selectedEvent!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))){
                croppedString += array[i]
            }
            //            if array.count != 1 && i != array.count - 1  {
            //                croppedString += ","
            //            }
        }
        
        return croppedString
    }
}

