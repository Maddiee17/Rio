//
//  FavoritesViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 18/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController {

    @IBOutlet weak var tableView : UITableView!
    let manager = WSManager.sharedInstance
    var reminderArray = NSArray()
    var centreLabel: UILabel?
    var disciplineArray = [String]()
    var splittedDict = Dictionary<String , Array<AnyObject>>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setupLeftMenuButton()
        tableView.sectionHeaderHeight = 5.0;
        tableView.sectionFooterHeight = 5.0;
        self.title = "Added Reminders"
    }
    
    func setUp() {
        if Reachability.isConnectedToNetwork() {
            
            KVNProgress.showWithStatus("Loading Favourites..")
            manager.getReminders({ (model) in
                print(model)
                self.reminderArray = self.sortArray(RioRootModel.sharedInstance.favoritesArray!)
                dispatch_async(dispatch_get_main_queue(), {
                    if(self.reminderArray.count == 0){
                        KVNProgress.dismiss()
                        self.noDataLabel()
                        self.centreLabel?.hidden = false
                    }
                    else {
                        self.sortDataBasedOnDate()
                        self.centreLabel?.hidden = true
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                        KVNProgress.dismiss()
                    }
                })
            }) { (error) in
                KVNProgress.showErrorWithStatus("Failed Loading Favourites..")
            }
        }
        else{
            RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
        }
    }
    
    func noDataLabel()  {
        centreLabel?.removeFromSuperview()
        centreLabel = UILabel(frame: CGRectMake(0, 0, 300, 50))
        centreLabel!.translatesAutoresizingMaskIntoConstraints = true
        centreLabel!.numberOfLines = 2
        centreLabel!.text = "No Reminders Added"
        self.view.addSubview(centreLabel!)
        
        centreLabel!.center = CGPointMake(self.view.bounds.midX, self.view.bounds.midY)
        centreLabel!.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
    }
    
    func sortArray(reminderArray:NSArray) -> NSArray{
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "eventName", ascending: true)
        let sortedResults: NSArray = reminderArray.sortedArrayUsingDescriptors([descriptor])
        return sortedResults
    }
    
    func setupLeftMenuButton() {
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(HomeViewController.leftDrawerButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = leftDrawerButton
    }
    
    func leftDrawerButtonPress(leftDrawerButtonPress: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: { _ in })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("favCell") as? EventCell
        
        let key = self.disciplineArray[indexPath.section]
        let localDict = self.splittedDict[key] as! [NSDictionary]
 
//        let localDict = self.reminderArray[indexPath.section]
        cell?.eventVenue.text = localDict[indexPath.row].objectForKey("eventVenue") as? String
        cell?.eventName.text =  localDict[indexPath.row].objectForKey("eventDetails") as? String
        cell?.eventTime.text =  localDict[indexPath.row].objectForKey("scheduledDateTime") as? String
        cell?.eventMedals.text =  localDict[indexPath.row].objectForKey("isMedalAvailable") as? String
        cell?.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        
        return self.splittedDict.keys.count ?? 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let key = self.disciplineArray[section]
        return (self.splittedDict[key]?.count) ?? 0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return 50
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
    {
        return self.disciplineArray[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 105.0
    }
    
    func sortDataBasedOnDate()
    {
        for reminderDict in self.reminderArray
        {
            if self.disciplineArray.contains(reminderDict.valueForKey("eventName") as! String) == false {
                self.disciplineArray.append(reminderDict.valueForKey("eventName") as! String)
            }
        }
        for discipline in self.disciplineArray {
            let predicate = NSPredicate(format: "eventName CONTAINS[cd] %@", discipline)
             let valuesDict = self.reminderArray.filteredArrayUsingPredicate(predicate)
                print(valuesDict)
                splittedDict.updateValue(valuesDict, forKey: discipline)
        }
//        print(self.datesArray)
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
