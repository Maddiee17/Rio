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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLeftMenuButton()
       
        // Do any additional setup after loading the view.
    }
    
    func setUp() {
        if Reachability.isConnectedToNetwork() {
            
            KVNProgress.showWithStatus("Loading Favourites..")
            manager.getReminders({ (model) in
                print(model)
                self.reminderArray = self.sortArray(RioRootModel.sharedInstance.favoritesArray!)
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                    KVNProgress.dismiss()
                })
            }) { (error) in
                print(error)
                KVNProgress.showErrorWithStatus("Failed Loading Favourites..")
            }
        }
        else{
            RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
        }
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
        
        let localDict = self.reminderArray[indexPath.section]
        cell?.eventVenue.text = localDict.objectForKey("eventVenue") as? String
        cell?.eventName.text = localDict.objectForKey("eventName") as? String
        cell?.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
        return cell!
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        
        return (reminderArray.count) > 0 ? (reminderArray.count) : 0
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 105.0
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
