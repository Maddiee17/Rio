//
//  LeftNavViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 16/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class LeftNavViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.tableView.backgroundColor = UIColor(hex : 0xecf0f1)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: nil)
                self.logoutUser()
            default:
                break
            }
            
        }
        
    }
    
    func logoutUser()  {
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyBoard.instantiateViewControllerWithIdentifier("LoginVC")
        self.navigationController?.presentViewController(loginVC, animated: true, completion: nil)
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
