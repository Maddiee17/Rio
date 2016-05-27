//
//  SubCategoryViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 13/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class SubCategoryViewController: UIViewController,UIGestureRecognizerDelegate {

    var categorySelected : String?
    var dataManager = RioDatabaseInteractor()
    var subCategoryModelLocal : RioSubCategoryModel?
    var subCategoryArray : [String]?
    var eventArray : [RioEventModel]?
    var selectedEvent : String?
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCategoryModel()
        let view = UIView(frame: CGRectZero)
        self.tableView.tableHeaderView = view
        // Do any additional setup after loading the view.
        self.title = categorySelected
        setUpLeftBarButton()
        let tblView =  UIView(frame: CGRectZero)
        self.tableView.tableFooterView = tblView
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        setupInfoButton()

        
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil) {
            self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
//            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }
    }
    
    func setupInfoButton() {
        
        let barButton = UIBarButtonItem(image: UIImage(named: "info"), style: .Done, target: self, action: #selector(SubCategoryViewController.infoButtonTapped))
        barButton.tintColor = UIColor(hex:0xD21F69)
        self.navigationItem.rightBarButtonItem = barButton
    }
    
    func infoButtonTapped() {
        
        let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryInfoVC") as? UINavigationController
        (navigationController?.viewControllers[0] as! CategoryInfoViewController).subCategoryModel = subCategoryModelLocal!
        self.presentViewController(navigationController!, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mm_drawerController.openDrawerGestureModeMask = .None
        self.mm_drawerController.closeDrawerGestureModeMask = .None
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self;

    }
    func setUpLeftBarButton() {
        
        let btnBackImage = UIImage(named: "ico-left-arrow")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let btnBack = UIBarButtonItem(image: btnBackImage, style: .Plain, target: self, action: #selector(SubCategoryViewController.backButtonTapped(_:)))
        btnBack.tintColor = UIColor.darkGrayColor()
        self.navigationItem.leftBarButtonItem = btnBack
    }
    
    func backButtonTapped(sender:AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil && gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            return true
        }
        return false
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
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
                        self.handleNotification()
                    })
                }
                
            })})
    }
    
    func handleNotification()
    {
        if RioRootModel.sharedInstance.isPushedFromNotification == true
        {
            infoButtonTapped()
        }
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
        if let count = self.subCategoryArray?.count{
            return count
        }
        else{
            return  0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("subcategorycell") as! SubCategoryTableViewCell
        if(subCategoryArray?.count > 0){
            
            cell.userInteractionEnabled = false
            cell.accessoryType = .None
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0,right: 0)
            
            cell.titleLabel.text = (subCategoryArray![indexPath.row] as String).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0,right: 0)
            cell.accessoryType = .DisclosureIndicator
            cell.userInteractionEnabled = true
            cell.textLabel?.textColor = UIColor(hex:0x2c3e50)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let eventSelected = (tableView.cellForRowAtIndexPath(indexPath) as! SubCategoryTableViewCell).titleLabel.text
        _ = eventSelected!.componentsSeparatedByString(" ")
        
                let sqlStmt = "SELECT * from Event WHERE Discipline = ? GROUP BY SessionCode"
        
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                    self.dataManager.fetchEventsFromDB(sqlStmt, categorySelected: self.categorySelected!) { (results) -> Void in
                        self.eventArray = results
//                        let predicate = NSPredicate(format: "DescriptionLong CONTAINS[d] %@", eventSplitted[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
                        let newArray = self.filterArrayBasedOnCategory(eventSelected!)
                        NSLog("Event array count %d",(newArray.count))
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                            let eventDetailsVC = storyBoard.instantiateViewControllerWithIdentifier("EventDetailVC") as! EventDetailsTableViewController
                            eventDetailsVC.eventsFilteredArray = newArray
                            eventDetailsVC.selectedEvent = self.selectedEvent!
                            self.navigationController?.pushViewController(eventDetailsVC, animated: true)
                        })
                    }
        
                }
        
    }


    
    func filterArrayBasedOnCategory(eventSelected:String) -> NSArray
    {
        var predicate : NSPredicate?
        let eventSplitted = eventSelected.componentsSeparatedByString(" ")

        switch categorySelected! {
        case "Boxing", "Athletics", "Canoe slalom", "Canoe sprint", "Cycling track", "Cycling road", "Diving", "Fencing", "Judo", "Rowing", "Archery", "Synchronised swimming", "Sailing" ,"Swimming", "Weightlifting", "Wrestling - Freestyle", "Wrestling - Greco- roman", "Shooting", "Taekwondo", "Gymnastics - Rhythmic":
            predicate = NSPredicate(format: "DescriptionLong CONTAINS[d] %@", eventSelected)
            selectedEvent = eventSelected
            
        default:
            predicate = NSPredicate(format: "DescriptionLong CONTAINS[d] %@", eventSplitted[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()))
            selectedEvent = eventSplitted[0]

        }
        
        return (self.eventArray! as NSArray).filteredArrayUsingPredicate(predicate!)
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 60
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
