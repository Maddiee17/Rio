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
    var cellView : UITableViewCell?
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(EventDetailsTableViewController.reloadData(_:)), name: "refreshTable", object: nil)
        
        tableView.sectionHeaderHeight = 5.0;
        tableView.sectionFooterHeight = 5.0;
        
        self.title = "Event Details"
        sortDataBasedOnDate()
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
        return self.datesArray[section]
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventCell
        
        let key = self.datesArray[indexPath.section]
        
        
        let localObj = self.splittedDict[key]
        
//        cell.eventTime.text = localObj![indexPath.row].StartTime
        cell.eventVenue.text = localObj![indexPath.row].VenueName
        cell.eventMedals.text = localObj![indexPath.row].Medal
        let localDate = RioUtilities.sharedInstance.calculateFireDate(localObj![indexPath.row]).description
        let splitArray = localDate.componentsSeparatedByString(" ")
        cell.eventDate.text = splitArray[0]
        cell.eventTime.text = splitArray[1]
        
        cell.eventName.text = filterDescription(localObj![indexPath.row].DescriptionLong!)
        if (notificationEnabledCells.contains(localObj![indexPath.row].Sno!)) {
            cell.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
            cell.notificationButton.tag = 2
        }
        else{
            cell.notificationButton.setImage(UIImage(named: "ico-bell"), forState: .Normal)
            cell.notificationButton.tag = 1
        }
        
        cell.delegate = self
        cell.eventImage.image = UIImage(named: "ico-wrestle")
        return cell
    }
    
    func findAddedReminders()
    {
        if let remidersArray =  RioRootModel.sharedInstance.addedReminderArray{
            self.notificationEnabledCells = remidersArray
        }
    }
    
    func filterDescription(actualString:String) -> String{
        
        var croppedString = ""
        let array = actualString.componentsSeparatedByString("|")
        var i = 0
        for (i = 0; i<array.count; i += 1) {
            
            if(array[i].containsString(selectedEvent!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))){
                croppedString += array[i]
            }
        }
        
        return croppedString
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
            if self.datesArray.contains((eventModel as! RioEventModel).Date!) == false {
                self.datesArray.append((eventModel.Date)!!)
            }
        }
        for date in self.datesArray {
            let predicate = NSPredicate(format: "Date CONTAINS[cd] %@", date)
            let valuesArray = self.eventsFilteredArray.filteredArrayUsingPredicate(predicate) as! [RioEventModel]
            print(valuesArray)
            splittedDict.updateValue(valuesArray, forKey: date)
        }
        print(self.datesArray)
    }
    
}
