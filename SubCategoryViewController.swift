//
//  SubCategoryViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 13/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class SubCategoryViewController: UIViewController {

    var categorySelected : String?
    var dataManager = RioDatabaseInteractor()
    var subCategoryModelLocal : RioSubCategoryModel?
    var subCategoryArray : [String]?
    var eventArray : [RioEventModel]?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCategoryModel()
        let view = UIView(frame: CGRectZero)
        self.tableView.tableHeaderView = view
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - DB Fetch
    
    func fetchCategoryModel()
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            
            self.dataManager.fetchSubCategoryFromDB(self.categorySelected!, completionBlock: { (results) -> Void in
                
                if(results.count > 0)
                {
                    self.subCategoryModelLocal = results.first
                    self.getSubCategoryValues()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.reloadData()
                    })
                }
                
            })})
    }
    
    func getSubCategoryValues()
    {
        let subCategoryString = self.subCategoryModelLocal?.Subcategory
        let array = subCategoryString?.componentsSeparatedByString("|")
        self.subCategoryArray = array
    }
    
    // MARK: - Table view delegates


    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.subCategoryArray?.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("subcategorycell")
        if(subCategoryArray?.count > 0){
            cell?.textLabel?.text = subCategoryArray![indexPath.row]
            cell?.accessoryType = .DisclosureIndicator
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let eventSelected = (tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!
        
                let sqlStmt = "SELECT * from Event WHERE Discipline = ?"
        
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                    self.dataManager.fetchEventsFromDB(sqlStmt, categorySelected: self.categorySelected!) { (results) -> Void in
                        self.eventArray = results
                        let predicate = NSPredicate(format: "DescriptionLong CONTAINS[cd] %@", eventSelected.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                        let newArray = (self.eventArray! as NSArray).filteredArrayUsingPredicate(predicate)
                        NSLog("Event array count %d",(newArray.count))
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                            let eventDetailsVC = storyBoard.instantiateViewControllerWithIdentifier("EventDetailVC") as! EventDetailsTableViewController
                            eventDetailsVC.eventsFilteredArray = newArray
                            eventDetailsVC.selectedEvent = eventSelected
                            self.navigationController?.pushViewController(eventDetailsVC, animated: true)
                        })
                    }
        
                }
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
