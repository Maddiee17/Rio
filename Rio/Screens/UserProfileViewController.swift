//
//  UserProfileViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 08/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchReminderInBackground()
        //self.avatarImage = UIImageView(frame: CGRectMake((self.profileImageBackgroundView.frame.width)/2 ,(self.profileImageBackgroundView.frame.height)/2, 50, 50))
        self.avatarImage!.layer.cornerRadius = 5.0
        self.avatarImage?.clipsToBounds = true
        self.navigationController?.navigationBarHidden = true
        self.goAheadButton.layer.cornerRadius = 20.0
        self.goAheadButton.layer.borderColor = UIColor.orangeColor().CGColor
        self.goAheadButton.layer.borderWidth = 1.0
//        self.avatarImage?.layer.borderWidth = 2.0
//        self.avatarImage?.layer.borderColor = UIColor.orangeColor().CGColor
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
        if (Reachability.isConnectedToNetwork()){
            
            fetchUserProfilePic()
        }
        
        if RioRootModel.sharedInstance.isPushedFromNotification == true
        {
            self.presentVC()
        }
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
                })
            })
        })
    }

    func fetchUserProfilePic() {
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            let fbId = userDataDict?.objectForKey("facebookId") ?? ((userProfileArray?.first)! as RioUserProfileModel).facebookId
         let request = FBSDKGraphRequest.init(graphPath: String(format: "http://graph.facebook.com/%@/picture?type=large",fbId as! String), parameters: nil, HTTPMethod: "GET")
            request.startWithCompletionHandler({ (connection, result, error) in
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutTapped(sender:UIButton)
    {
        FBSDKLoginManager().logOut()
        GIDSignIn.sharedInstance().signOut()
        dataBaseInteractor.clearUserProfileTable()
        NSUserDefaults.standardUserDefaults().removeObjectForKey("userId")
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
