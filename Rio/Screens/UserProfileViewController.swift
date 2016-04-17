//
//  UserProfileViewController.swift
//  Rio
//
//  Created by Pearson_3 on 08/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {

    var userDataDict : NSDictionary?
    var dataBaseInteractor = RioDatabaseInteractor()
    var userProfileArray : [RioUserProfileModel]?
    
    @IBOutlet weak var nameLabel: UILabel!
    var avatarImage: UIImageView?
    @IBOutlet weak var goAheadButton : UIButton!
    @IBOutlet weak var profileImageBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.avatarImage = UIImageView(frame: CGRectMake(self.profileImageBackgroundView.center.x + 50 ,self.profileImageBackgroundView.center.y - 50, 50, 50))
        self.avatarImage!.layer.cornerRadius = 25.0
        self.avatarImage?.clipsToBounds = true
        self.navigationController?.navigationBarHidden = true
        self.goAheadButton.layer.cornerRadius = 20.0
        self.goAheadButton.layer.borderColor = UIColor.orangeColor().CGColor
        self.goAheadButton.layer.borderWidth = 1.0
        self.avatarImage?.layer.borderWidth = 2.0
        self.avatarImage?.layer.borderColor = UIColor.orangeColor().CGColor
        self.profileImageBackgroundView.addSubview(self.avatarImage!)
        
        if(userDataDict != nil){
            self.nameLabel.text = userDataDict?.valueForKey("name") as? String
            let photo = userDataDict?.valueForKey("photoUrl") as? String
            let photoURL = NSURL(string: photo!)
            self.avatarImage!.image = UIImage(data: NSData(contentsOfURL: photoURL!)!)
        }
        else {
            self.dataBaseInteractor.fetchUserProfile({ (results) -> Void in
                self.userProfileArray = results
                self.nameLabel.text = self.userProfileArray?.first?.name
                let photo = self.userProfileArray?.first?.photoUrl
                let photoURL = NSURL(string: photo!)
                self.avatarImage!.image = UIImage(data: NSData(contentsOfURL: photoURL!)!)
            })
        }
        
        fetchUserProfilePic()
        
    }

    func fetchUserProfilePic() {
        
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            
            let fbId = userDataDict?.objectForKey("facebookId") ?? ((userProfileArray?.first)! as RioUserProfileModel).facebookId
         let request = FBSDKGraphRequest.init(graphPath: String(format: "http://graph.facebook.com/%@/picture?type=large",fbId as! String), parameters: nil, HTTPMethod: "GET")
            request.startWithCompletionHandler({ (connection, result, error) in
                
                print(result)
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
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let loginVC = storyBoard.instantiateViewControllerWithIdentifier("LoginVC")
        self.navigationController?.presentViewController(loginVC, animated: true, completion: nil)
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
