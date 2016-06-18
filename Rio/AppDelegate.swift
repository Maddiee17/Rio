//
//  AppDelegate.swift
//  Rio
//
//  Created by Madhur Mohta on 05/02/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit
let kIsFirstLaunch = "isFirstLaunch"

import Fabric
import TwitterKit
import Crashlytics
import WatchConnectivity

@available(iOS 9.0, *)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate {

    var window: UIWindow?
    var dataBaseInteractor = RioDatabaseInteractor()
    var userProfile : [RioUserProfileModel]?
    var wsManager = WSManager.sharedInstance
    var retryCount = 0

    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        getServerDBVersion()

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
  //      UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert , .Badge, .Sound], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()

        let objDBManager = RioDatabaseManager.sharedInstance
        objDBManager.initDatabase()
        
        dataBaseInteractor.fetchUserProfile { (results) -> Void in
            
            if(results.count > 0){
                self.userProfile = results
                NSUserDefaults.standardUserDefaults().setObject(self.userProfile?.first!.userId, forKey: "userId")
                NSUserDefaults.standardUserDefaults().synchronize()
//                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                let userProfileVC = storyBoard.instantiateViewControllerWithIdentifier("UserProfileVC")
//                self.window?.rootViewController = userProfileVC
//                self.fetchReminderInBackground()
                self.fetchReminderInBackground()
            }
        }

        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        self.wsManager.verifyCredentialsAndGetAccessToken { (accessToken, error) -> Void in
            print(accessToken)
            print(error)
        }
        
        Fabric.with([Twitter.self, Crashlytics.self])
        customizeNavigationBar()
        getImagesURL()
        
        if let _ = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] {
            NSLog("app Launched with notification posted ******")
            RioRootModel.sharedInstance.isPushedFromNotification = true
            self.application(application, didReceiveRemoteNotification:(launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey])! as! [NSObject : AnyObject])
        }
        
        if WCSession.isSupported() {
            session = WCSession.defaultSession()
        }

        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handleURL(url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
    
        var messageFromPayload : String?
        var bodyFromPayload : String?
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["title"] as? NSString {
                    messageFromPayload = message as String
                    bodyFromPayload = alert["body"] as! String
                    RioRootModel.sharedInstance.userInfoDict = alert as [NSObject : AnyObject]
                }
            } else if let alert = aps["alert"] as? NSString {
                //Do stuff
                messageFromPayload = alert as String
            }
            
            if (UIApplication.sharedApplication().applicationState == .Active) {
                let alertController = UIAlertController(title: messageFromPayload, message: bodyFromPayload, preferredStyle: .Alert)
                let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .Cancel) { action -> Void in
                }
                alertController.addAction(closeAction)
                let viewController: UIViewController = getTopViewController()
                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                self.handleLocalNotifictionForForegroundState()
//                let userInfo = ["category":messageFromPayload!] as [NSObject : AnyObject]
                RioRootModel.sharedInstance.isPushedFromNotification = true
                NSLog("Notification posted ******")
                print("Notification posted ***********")
//                NSNotificationCenter.defaultCenter().postNotificationName("localNotificationTapped", object: nil, userInfo:userInfo)
                //self.handleLocalNotifictionForForegroundState(messageFromPayload!)
            }
        }
    }
    
    func getTopViewController() -> UIViewController {
        let signInVC =  self.window?.rootViewController as! SplashScreenViewController
        
        var viewController: UIViewController = signInVC
        
        while (viewController.presentedViewController != nil) {
            var tempViewController = viewController.presentedViewController
            
            if (tempViewController?.isKindOfClass(UITabBarController) != nil) {
                tempViewController = (tempViewController as! UITabBarController).selectedViewController
                
                if (tempViewController?.isKindOfClass(UINavigationController) != nil) {
                    viewController = (tempViewController as! UINavigationController).visibleViewController!
                }
                else {
                    viewController = tempViewController!
                }
            }
            else {
                viewController = tempViewController!
            }
        }
        
        return viewController
    }


    func handleLocalNotifictionForForegroundState() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let userProfileVC = storyBoard.instantiateViewControllerWithIdentifier("UserProfileVC")
        self.window?.rootViewController = userProfileVC
    }
    
    func getServerDBVersion() {
        
        self.wsManager.getServerDBVersion()
    }
    
    func getImagesURL() {
        let operation = GetImagesOperation()
        RioRootModel.sharedInstance.backgroundQueue.addOperation(operation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        
        NSUserDefaults.standardUserDefaults().setObject(deviceTokenStr, forKey: "notificationId")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if let emailIdValue = self.userProfile?.first?.emailId {// {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
//                self.wsManager.updateDeviceToken(deviceTokenStr, email: emailIdValue, successBlock: { (response) in
//                    print(response)
//                    }, errorBlock: { (error) in
//                        print(error)
//                })
//            }
//
//        }
        updateDeviceToken(deviceTokenStr, emailId: emailIdValue)
        }
        
        print(deviceTokenStr)
    }
    
    func fetchReminderInBackground()
    {
        let getReminderOperation = GetReminderOperation()
        RioRootModel.sharedInstance.backgroundQueue.addOperation(getReminderOperation)
    }
    
    
    func updateDeviceToken(deviceToken : String, emailId : String)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.wsManager.updateDeviceToken(deviceToken, email: emailId, successBlock: { (response) in
                print(response)
                }, errorBlock: { (error) in
                    print(error)
                    self.retryCount += 1
                    if(self.retryCount < 4){
                        self.updateDeviceToken(deviceToken, emailId: emailId)
                    }
            })
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.description)
    }
    
    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        
        let deviceTokenStr = deviceToken.description.componentsSeparatedByCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet).joinWithSeparator("")

        return deviceTokenStr
    }

    func customizeNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor(hex: 0xecf0f1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor(hex: 0x2c3e50), NSFontAttributeName: UIFont.systemFontOfSize(18)]
        UINavigationBar.appearance().translucent = false
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    

    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        let objDBManager = RioDatabaseManager.sharedInstance
        objDBManager.initDatabase()

        if  message["model"] as? String == "category"{
                self.dataBaseInteractor.fetchCategoryFromDB({ (results) in
                    if results.count > 0{
                        let responseArray = NSMutableArray()
                        for model in results {
                            responseArray.addObject((model as RioCategoryModel).type!)
                        }
                        let dict = ["categoryModel" : responseArray] as NSDictionary
                        replyHandler(dict as! [String : AnyObject])
                    }
                })
        }
        else if message["model"] as? String == "event"{
            
            let sqlStmt = "SELECT * from Event WHERE Discipline = ? GROUP BY SessionCode"
            let type = message["categorySelected"] as? String
            self.dataBaseInteractor.fetchEventsFromDB(sqlStmt, categorySelected: type!, completionBlock: { (results) in
                
                if results.count > 0
                {
                    let responseArray = NSMutableArray()
                    for model in results{
                        
                        let localDateNTime = RioUtilities.sharedInstance.calculateFireDate(model ).description
                        model.Date = localDateNTime.componentsSeparatedByString(" ")[0]
                        model.StartTime = localDateNTime.componentsSeparatedByString(" ")[1]
                    }
                    
                    for model in results {
                    
                        let dict = NSMutableDictionary()
                        dict.setValue(model.Discipline, forKey: "Discipline")
                        dict.setValue(model.StartTime, forKey: "StartTime")
                        dict.setValue(model.Description, forKey: "Description")
                        dict.setValue(model.Medal, forKey: "Medal")
                        dict.setValue(model.Date, forKey: "Date")
                        dict.setValue(model.VenueName, forKey: "VenueName")
                        dict.setValue(model.Sno, forKey: "Sno")
                        dict.setValue(model.Notification, forKey: "reminderId")

                        responseArray.addObject(dict)
                    }
                    let dict = ["eventModel" : responseArray] as NSDictionary
                    replyHandler(dict as! [String : AnyObject])
                }
                
            })
        }
        else if message["model"] as? String == "reminder"
        {
            let remindersArray = RioRootModel.sharedInstance.addedReminderArray
            if (remindersArray != nil) {
                let dict = ["remindersArray" : remindersArray!] as NSDictionary
                replyHandler(dict as! [String : AnyObject])
            }
        }
        else if message["model"] as? String == "updateReminderId" {
            
            let Sno = message["Sno"] as! String
            let reminderId = message["reminderId"] as! String
            
            self.dataBaseInteractor.updateReminderIdInDB(reminderId, serialNo: Sno)
            RioRootModel.sharedInstance.appendSnoToNotificationEnabledArray(Sno)
        }
        else if message["model"] as? String == "removeReminderId" {
            
            let Sno = message["Sno"] as! String
            
            self.dataBaseInteractor.updateReminderIdInDB("", serialNo: Sno)
            RioRootModel.sharedInstance.removeSnoFromNotificationEnabledArray(Sno)
        }

        else
        {
            if self.userProfile?.count > 0
            {
                let responseArray = NSMutableArray()
                for model in self.userProfile! {
                    
                    let dict = NSMutableDictionary()
                    dict.setValue(model.emailId, forKey: "emailId")
                    dict.setValue(model.userId, forKey: "userId")
                    responseArray.addObject(dict)
                }
                let dict = ["userProfileModel" : responseArray] as NSDictionary
                replyHandler(dict as! [String : AnyObject])
            }
            
        }
    }
    // session?.sendMessage(["model":"updateReminderId", "Sno" : serialNo, "reminderId" : reminderId], replyHandler: { (response) in

}

