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
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLeftBarButton()
        findAddedReminders()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"reloadData:", name: "refreshTable", object: nil)

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
        return eventsFilteredArray.count
    }

     func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("eventCell", forIndexPath: indexPath) as! EventCell
        
        let localObj = self.eventsFilteredArray[indexPath.section] as! RioEventModel
        cell.eventTime.text = localObj.StartTime
        cell.eventVenue.text = localObj.VenueName
        cell.eventMedals.text = localObj.Medal
        cell.eventName.text = filterDescription(localObj.DescriptionLong!)
        if (notificationEnabledCells.contains(localObj.Sno!)) {
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
        notificationButtonTappedCellModel = self.eventsFilteredArray[(indexPath?.section)!] as? RioEventModel
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
        let eventObj = self.eventsFilteredArray.objectAtIndex((indexPathOfCell?.section)!) as! RioEventModel
        if cellTag == "1" {
            self.notificationEnabledCells = RioRootModel.sharedInstance.appendSnoToNotificationEnabledArray(eventObj.Sno!)
        }
        else{
            self.notificationEnabledCells = RioRootModel.sharedInstance.removeSnoFromNotificationEnabledArray(eventObj.Sno!)
        }
        self.tableView.reloadRowsAtIndexPaths([indexPathOfCell!], withRowAnimation: .Automatic)
    }
        
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "popoverSegue"
        {
            let popoverPresentationController = segue.destinationViewController.popoverPresentationController
            popoverPresentationController!.sourceView = self.cellView
            popoverPresentationController!.sourceRect = self.frameForButton!
            popoverPresentationController?.delegate = self
            
        }
    }
    

}
