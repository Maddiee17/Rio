//
//  SplashScreenViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 12/05/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit


class SplashScreenViewController: UIViewController {

    var dataBaseInteractor = RioDatabaseInteractor()
    var confettiView: SAConfettiView!
    var userProfile : [RioUserProfileModel]?
    var manger = WSManager.sharedInstance
    
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
        
        confettiView.intensity = 1
        confettiView.type = .Diamond
        
//        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseIn, animations: {
            self.view.addSubview(self.confettiView)
//            }, completion: nil)
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        confettiView.startConfetti()
        
        if(NSUserDefaults.standardUserDefaults().stringForKey(kIsFirstLaunch) == nil)
        {
            NSUserDefaults.standardUserDefaults().setValue("1", forKey: "DBVersion")
            NSUserDefaults.standardUserDefaults().setValue("true", forKey: kIsFirstLaunch)
            NSUserDefaults.standardUserDefaults().synchronize()
            if checkDBVersion() {
                self.performSegueWithIdentifier("Download_Segue", sender: self)
                NSUserDefaults.standardUserDefaults().setValue("true", forKey: "NewDBAvailableAndFirstLaunch")
                NSUserDefaults.standardUserDefaults().setValue("false", forKey: "NewDBAvailableAndSubsLaunch")
            }
            else {
                self.performSelector(#selector(SplashScreenViewController.showOnboarding), withObject: nil, afterDelay: 1.0)
            }
        }
        else {
            if checkDBVersion() {
                self.performSegueWithIdentifier("Download_Segue", sender: self)
                NSUserDefaults.standardUserDefaults().setValue("true", forKey: "NewDBAvailableAndSubsLaunch")
                NSUserDefaults.standardUserDefaults().setValue("false", forKey: "NewDBAvailableAndFirstLaunch")
            }
            else {
                self.performSelector(#selector(SplashScreenViewController.checkForUserProfile
                    ), withObject: nil, afterDelay: 1.0)
            }
        }
    }
    
    func checkDBVersion() -> Bool {
        
        let localDbVersion = NSUserDefaults.standardUserDefaults().objectForKey("DBVersion") as? String
        let serverDbVersion = NSUserDefaults.standardUserDefaults().objectForKey("ServerDBVersion") as? String
        
        if serverDbVersion == nil {
            return false
        }
        if localDbVersion != serverDbVersion
        {
            return true
        }
        return false
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        if confettiView.isActive() {
            confettiView.stopConfetti()
        }
    }
    
    func showOnboarding()
    {
        var onboardVC : OnboardingViewController?
        
        let firstPage = OnboardingContentViewController(title: "Welcome to Olympifire", body: "Don't miss a single game of this year's biggest sporting event", image: UIImage(named: "ico-rocket"), buttonText: "") { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        }
        
        let secondPage = OnboardingContentViewController(title: "Be Social!!", body: "Get all the live news of \"Rio Games\" from twitter. Retweet them right from here", image: UIImage(named: "ico-twitter"), buttonText: "") { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        }
        
        var myString : NSMutableAttributedString?
        let attachment = NSTextAttachment()
        attachment.image = UIImage(named: "addReminder")
        attachment.bounds = CGRectMake(0, 0, self.view.frame.size.width - 50, 70)
        let attachmentString = NSAttributedString(attachment: attachment)
        myString = NSMutableAttributedString(string: "Notification options for game start, 1 hour before and more. Add reminders for your favourites, Just like these \n\n")
        myString!.appendAttributedString(attachmentString)
        
        let fourthPage = OnboardingContentViewController(title: "Reminders", body: "", image: UIImage(named: "ico-alarm"), buttonText: "Get Started") { () -> Void in
            
            let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC")
            let onBoardVCC = self.navigationController?.viewControllers.last
            onBoardVCC?.presentViewController(loginVC!, animated: true, completion: {
                UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert , .Badge, .Sound], categories: nil))
                UIApplication.sharedApplication().registerForRemoteNotifications()
            })
        }
        
        onboardVC = OnboardingViewController(backgroundImage: UIImage(named: "launch"), contents: [firstPage, secondPage,fourthPage])
        onboardVC!.shouldFadeTransitions = true
        onboardVC!.fadePageControlOnLastPage = true
        onboardVC!.fadeSkipButtonOnLastPage = true
        onboardVC!.shouldBlurBackground = true
        
        let modelName = UIDevice.currentDevice().modelName
        
        if modelName == "iPhone 4" || modelName == "iPhone 4s" || modelName == "iPhone 5" || modelName == "iPhone 5c" || modelName == "iPhone 5s"{
            
            onboardVC!.topPadding = 20
            onboardVC!.underIconPadding = 8
            onboardVC!.underTitlePadding = 8
            onboardVC!.bottomPadding = 8
            onboardVC!.underPageControlPadding = 5
            
            myString = NSMutableAttributedString(string: "Notification options for game start and more. Add reminders for your favourites    ")
        }
        
        
        fourthPage.bodyLabel.attributedText = myString
        
        
        
        self.navigationController?.pushViewController(onboardVC!, animated: true)//presentViewController(onboardVC!, animated: true, completion: nil)
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
