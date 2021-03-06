//
//  UserProfileViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 08/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit
import GoogleMobileAds

class UserProfileViewController: UIViewController {

    var userDataDict : NSDictionary?
    var dataBaseInteractor = RioDatabaseInteractor()
    var userProfileArray : [RioUserProfileModel]?
    let manager = WSManager.sharedInstance
    let isPushedFromNotification = false
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView?
    @IBOutlet weak var goAheadButton : UIButton!
    @IBOutlet weak var profileImageBackgroundView: UIView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var bannerAd: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bannerAd.adUnitID = "ca-app-pub-9377831525423293/3112670162"
        bannerAd.rootViewController = self
        let request = GADRequest()
        bannerAd.loadRequest(request)
        
        fetchReminderInBackground()
        //self.avatarImage = UIImageView(frame: CGRectMake((self.profileImageBackgroundView.frame.width)/2 ,(self.profileImageBackgroundView.frame.height)/2, 50, 50))
        self.avatarImage?.clipsToBounds = true
        self.navigationController?.navigationBarHidden = true
        self.goAheadButton.layer.cornerRadius = 25.0
        self.goAheadButton.layer.borderColor = UIColor(hex : 0x2c3e50).CGColor
        self.goAheadButton.layer.borderWidth = 1.0
        self.avatarImage?.layer.cornerRadius = 25.0
        self.avatarImage?.layer.borderWidth = 1.0
        self.avatarImage?.layer.borderColor =  UIColor(hex : 0x2c3e50).CGColor
        //self.profileImageBackgroundView.addSubview(self.avatarImage!)
        
        if(userDataDict != nil){
            self.nameLabel.text = userDataDict?.valueForKey("name") as? String
            let photo = userDataDict?.valueForKey("photoUrl") as? String
            fetchImage(photo!)
        }
        else {
            self.dataBaseInteractor.fetchUserProfile({ (results) -> Void in
                self.userProfileArray = results
                self.nameLabel.text = self.userProfileArray?.first?.name
                let photo = self.userProfileArray?.first?.photoUrl
//                let photoURL = NSURL(string: photo!)
                if (Reachability.isConnectedToNetwork()){
                    self.fetchImage(photo!)
                }
            })
        }
        
        RioRootModel.sharedInstance.userName = self.nameLabel.text
        
        let modelName = UIDevice.currentDevice().modelName
        
        if modelName == "iPhone 4" || modelName == "iPhone 4s"
        {
            nameLabel.hidden = true
        }
//        if (Reachability.isConnectedToNetwork()){
//            
//            fetchUserProfilePic()
//        }
//        
        if RioRootModel.sharedInstance.isPushedFromNotification == true
        {
            self.presentVC()
        }
        self.resetBadgeCount()
        
        let isGuest = NSUserDefaults.standardUserDefaults().objectForKey("isGuest") as? String
        
        if let isGuestValue = isGuest{
            if isGuestValue == "true" {
                logoutButton.hidden = true
            }
        }
    }
    
    
    func resetBadgeCount()
    {
        if UIApplication.sharedApplication().applicationIconBadgeNumber != 0
        {
            if let emailIdValue = self.userProfileArray?.first?.emailId {
                manager.resetBagdeCount(emailIdValue)
            }
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    override func viewWillAppear(animated: Bool) {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:"presentVC:", name: "localNotificationTapped", object: nil)

    }
    
    override func viewWillDisappear(animated: Bool) {
        
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "localNotificationTapped", object: nil)
    }
    
    func presentVC()
    {
//        let userInfo = notification.userInfo
//        let category =  userInfo!["category"] as! String
        NSLog("Present VC Called ******************")
        print("Present VC Called ******************")
        /*
        if category != "" {
            let homeViewViewController = self.storyboard?.instantiateViewControllerWithIdentifier("homeVC") as! HomeViewController
            homeViewViewController.isPushedFromNotification = true
            homeViewViewController.eventForNotification = category
            self.presentViewController(homeViewViewController, animated: true, completion: nil)
        } */
//        RioRootModel.sharedInstance.isPushedFromNotification = true
        self.performSegueWithIdentifier("DRAWER_SEGUE", sender: self)
    }
    
    func fetchImage(url:String) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.manager.fetchImageFromURL(url, successBlock: { (data) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.avatarImage!.image = UIImage(data: data)
                    RioRootModel.sharedInstance.profileImageData = data
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutTapped(sender:UIButton)
    {
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        dataBaseInteractor.clearUserProfileTable()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kAlertFirstDate)
        NSUserDefaults.standardUserDefaults().synchronize()
        RioRootModel.sharedInstance.addedReminderArray?.removeAll()
        RioRootModel.sharedInstance.favoritesArray = NSArray()
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyBoard.instantiateViewControllerWithIdentifier("LoginVC")
        self.navigationController?.presentViewController(loginVC, animated: true, completion: nil)
    }
    
    
    func fetchReminderInBackground()
    {
        let getReminderOperation = GetReminderOperation()
        RioRootModel.sharedInstance.backgroundQueue.addOperation(getReminderOperation)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "DRAWER_SEGUE" {
            let destinationVC = segue.destinationViewController as! MMDrawerController
            let centrevVC = self.storyboard?.instantiateViewControllerWithIdentifier("HomeViewController")
            destinationVC.centerViewController = centrevVC
            let leftVC = self.storyboard?.instantiateViewControllerWithIdentifier("LeftNavViewController")
            destinationVC.leftDrawerViewController = leftVC
        }
    }
}
