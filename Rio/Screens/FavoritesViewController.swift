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
    
    @IBOutlet weak var noRemindersLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUp()
        setupLeftMenuButton()
        tableView.sectionHeaderHeight = 5.0;
        tableView.sectionFooterHeight = 5.0;
        self.title = "Favourites"
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
            displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
        }
    }
    
    
    func displayAlertView(titleString: String, messageString: String) {
        
        if !isAlertAlreadyDisplayed {
            let alert: UIAlertView = UIAlertView(title: titleString, message: messageString, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            isAlertAlreadyDisplayed = true
        }
    }

    func noDataLabel()  {
//        centreLabel?.removeFromSuperview()
//        centreLabel = UILabel(frame: CGRectMake(0,0, 300, 50))
//        centreLabel!.translatesAutoresizingMaskIntoConstraints = true
//        centreLabel!.text = "No Reminders Added"
//        centreLabel!.center = self.view.center
//        centreLabel!.autoresizingMask = [UIViewAutoresizing.FlexibleLeftMargin, UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleTopMargin, UIViewAutoresizing.FlexibleBottomMargin]
//
//        self.view.addSubview(centreLabel!)
        
        self.tableView.hidden = true
        noRemindersLabel.hidden = false
    }
    
    func sortArray(reminderArray:NSArray) -> NSArray{
        let descriptor: NSSortDescriptor = NSSortDescriptor(key: "eventName", ascending: true)
        let sortedResults: NSArray = reminderArray.sortedArrayUsingDescriptors([descriptor])
        return sortedResults
    }
    
    func setupLeftMenuButton() {
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(HomeViewController.leftDrawerButtonPress(_:)))
        leftDrawerButton.tintColor = UIColor.darkGrayColor()
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
        let localDict = self.splittedDict[key] as? [NSDictionary]
        let localObj = localDict![indexPath.row]
        cell?.eventVenue.text = RioUtilities.sharedInstance.getVenueName((localObj.objectForKey("eventVenue") as? String)!)
        cell?.eventName.text = localObj.objectForKey("eventDetails") as? String
        let date = localObj.objectForKey("scheduledDateTime") as! NSNumber
        let dateTimeTuple = RioUtilities.sharedInstance.getDateStringFromTimeInterval(Int(date))
        cell?.eventTime.text = dateTimeTuple.1
        cell?.eventDate.text = dateTimeTuple.0
        let medalAvail = localObj.objectForKey("isMedalAvailable") as? Bool
        if medalAvail == false {
            cell?.eventMedals.text = "No"
            cell!.medalImageView.image = UIImage(named: "ico-nomedal")
        }
        else {
            cell?.eventMedals.text = "Yes"
            cell?.medalImageView.image = UIImage(named: "ico-medal")
        }
        cell?.medalImageView.image = cell?.medalImageView.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        cell?.medalImageView.tintColor = UIColor(hex :0x2c3e50)
        cell?.notificationButton.tintColor = UIColor(hex : 0x2c3e50)
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
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? // fixed font style. use custom view (UILabel) if you want something different
//    {
//        return self.disciplineArray[section]
//    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? // custom view for header. will be adjusted to default or specified header height
    {
        let view = UIView(frame: CGRectMake(0, 0 , self.view.frame.width, 100))
        let sectionTitle = self.disciplineArray[section]
        let image = UIImageView(image: UIImage(named: sectionTitle)?.imageWithRenderingMode(.AlwaysTemplate))
        image.frame = CGRectMake(10, 10, 20, 20)
        image.tintColor = UIColor(hex:0xD21F69)
        let label = UILabel(frame: CGRectMake (50, 0, self.view.frame.width ,40))
        label.text = sectionTitle
        view.backgroundColor = UIColor.whiteColor()
        view.addSubview(image)
        view.addSubview(label)
        return view
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
