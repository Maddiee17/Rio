//
//  EventDetailsTableViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 12/03/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class EventDetailsTableViewController: UIViewController,EventCellDelegate, UIPopoverPresentationControllerDelegate,reminderCellDelegate {

    var eventsFilteredArray = []
    var selectedEvent : String?
    var frameForButton : CGRect?
    var cellView : UITableViewCell?
    var notificationButtonTappedCellModel : RioEventModel?
    
    @IBOutlet weak var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let isReminderAdded = self.isReminderAddedForEvent(localObj)
        if isReminderAdded {
            cell.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
        }
        cell.delegate = self
        cell.eventImage.image = UIImage(named: "ico-wrestle")
        return cell
    }
    
    func isReminderAddedForEvent(localObj : RioEventModel) -> Bool
    {
        if let notificationId = localObj.Notification{
            
            let splitArray = notificationId.componentsSeparatedByString("+")
            let userId = NSUserDefaults.standardUserDefaults().stringForKey("userId")
            
            if ((splitArray[1] as String) == userId) {
                return true
            }
        }
        
        return false
    }
    
    func filterDescription(actualString:String) -> String{
        
        var croppedString = ""
        let array = actualString.componentsSeparatedByString("|")
        var i = 0
        for (i = 0; i<array.count; i++) {
            
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    func reminderAdded(forCell:EventCell)
    {
        let indexPath = self.tableView.indexPathForCell(forCell)
        self.tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
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
