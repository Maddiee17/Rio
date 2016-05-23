//
//  LeftNavViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 16/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class LeftNavViewController: UITableViewController {
    
    @IBOutlet var timerView: CountdownTimerView!
    var dataBaseInteractor = RioDatabaseInteractor()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.backgroundColor = UIColor(hex : 0xecf0f1)
       // self.shyNavBarManager.scrollView = self.tableView
        //self.shyNavBarManager.extensionView = timerView
        //self.shyNavBarManager.stickyExtensionView = true
        
        self.tableView.tableHeaderView = timerView
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        if NSUserDefaults.standardUserDefaults().objectForKey("isGuest") as? String == "true"{
            return 1
        }
        else{
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
        
        if indexPath.section == 0 {
            switch indexPath.row {
                
            case 0:
                self.mm_drawerController.centerViewController = self.storyboard!.instantiateViewControllerWithIdentifier("HomeViewController")
            case 1:
                self.mm_drawerController.centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("favViewController")
            case 2:
                self.mm_drawerController.centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsViewController")
            case 3:
                self.mm_drawerController.centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryListViewController")
            default:
                break
            }
        }
        else {
            switch indexPath.row {
            case 0:
                self.mm_drawerController.centerViewController = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC")//toggleDrawerSide(.Left, animated: true, completion: nil)
                self.logoutUser()
            default:
                break
            }
            
        }
        
    }
    
    func logoutUser()  {
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        dataBaseInteractor.clearUserProfileTable()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kAlertFirstDate)
        NSUserDefaults.standardUserDefaults().synchronize()
        RioRootModel.sharedInstance.addedReminderArray?.removeAll()
        RioRootModel.sharedInstance.favoritesArray = NSArray()
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
