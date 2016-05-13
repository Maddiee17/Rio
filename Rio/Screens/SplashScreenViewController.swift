//
//  SplashScreenViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 12/05/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    var dataBaseInteractor = RioDatabaseInteractor()
    var confettiView: SAConfettiView!
    var userProfile : [RioUserProfileModel]?
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        confettiView = SAConfettiView(frame: self.view.bounds)
        
        // Set colors (default colors are red, green and blue)
        confettiView.colors = [UIColor(red:0.95, green:0.40, blue:0.27, alpha:1.0),
                               UIColor(red:1.00, green:0.78, blue:0.36, alpha:1.0),
                               UIColor(red:0.48, green:0.78, blue:0.64, alpha:1.0),
                               UIColor(red:0.30, green:0.76, blue:0.85, alpha:1.0),
                               UIColor(red:0.58, green:0.39, blue:0.55, alpha:1.0)]
        
        // Set intensity (from 0 - 1, default intensity is 0.5)
        confettiView.intensity = 1
        
        // Set type
        confettiView.type = .Diamond
        
        // For custom image
        // confettiView.type = .Image(UIImage(named: "diamond")!)
        
        // Add subview
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: {
            self.view.addSubview(self.confettiView)
            }, completion: nil)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        confettiView.startConfetti()
        self.performSelector(#selector(SplashScreenViewController.checkForUserProfile), withObject: nil, afterDelay: 3.0)
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if confettiView.isActive() {
            confettiView.stopConfetti()
        }
    }
    
    func checkForUserProfile()
    {
        dataBaseInteractor.fetchUserProfile { (results) -> Void in
            
            if(results.count > 0){
                self.userProfile = results
                NSUserDefaults.standardUserDefaults().setObject(self.userProfile?.first!.userId, forKey: "userId")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.performSegueWithIdentifier("userProfileSegue", sender: self)
//                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                let userProfileVC = storyBoard.instantiateViewControllerWithIdentifier("UserProfileVC")
//                self.window?.rootViewController = userProfileVC
                //                self.fetchReminderInBackground()
            }
            else {
                self.performSegueWithIdentifier("loginSegue", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
