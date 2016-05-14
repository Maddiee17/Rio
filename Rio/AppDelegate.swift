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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var dataBaseInteractor = RioDatabaseInteractor()
    var userProfile : [RioUserProfileModel]?
    var wsManager = WSManager.sharedInstance
    var retryCount = 0

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert , .Badge, .Sound], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()

        let count = UIApplication.sharedApplication().scheduledLocalNotifications
        print(count?.count)
        
        let objDBManager = RioDatabaseManager.sharedInstance
        objDBManager.initDatabase()
        
//        dataBaseInteractor.fetchUserProfile { (results) -> Void in
//            
//            if(results.count > 0){
//                self.userProfile = results
//                NSUserDefaults.standardUserDefaults().setObject(self.userProfile?.first!.userId, forKey: "userId")
//                NSUserDefaults.standardUserDefaults().synchronize()
//                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//                let userProfileVC = storyBoard.instantiateViewControllerWithIdentifier("UserProfileVC")
//                self.window?.rootViewController = userProfileVC
////                self.fetchReminderInBackground()
//            }
//        }

        // Initialize Google sign-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        self.wsManager.verifyCredentialsAndGetAccessToken { (accessToken, error) -> Void in
            print(accessToken)
            print(error)
        }
        
        Fabric.with([Twitter.self])
        customizeNavigationBar()
        getImagesURL()
        
        if let _ = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] {
            NSLog("app Launched with notification posted ******")
            RioRootModel.sharedInstance.isPushedFromNotification = true
            self.application(application, didReceiveRemoteNotification:(launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey])! as! [NSObject : AnyObject])
        }
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
            self.resetBadgeCount()
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
                let viewController: UIViewController = (self.window?.rootViewController)!
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

    func handleLocalNotifictionForForegroundState() {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let userProfileVC = storyBoard.instantiateViewControllerWithIdentifier("UserProfileVC")
        self.window?.rootViewController = userProfileVC
    }
    
//    func application(application: UIApplication,
//        openURL url: NSURL, options: [String: AnyObject]) -> Bool {
//            return GIDSignIn.sharedInstance().handleURL(url,
//                sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
//                annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
//    }
    
    func getImagesURL() {
        let operation = GetImagesOperation()
        RioRootModel.sharedInstance.backgroundQueue.addOperation(operation)
    }
    
//    func fetchReminderInBackground()
//    {
//        let getReminderOperation = GetReminderOperation()
//        RioRootModel.sharedInstance.backgroundQueue.addOperation(getReminderOperation)
//    }
    
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
        self.updateDeviceToken(deviceTokenStr, emailId: emailIdValue)
        }
        
        print(deviceTokenStr)
    }
    
    func updateDeviceToken(deviceToken : String, emailId : String)
    {
        
        NSUserDefaults.standardUserDefaults().setObject(deviceToken, forKey: "notificationId")
        NSUserDefaults.standardUserDefaults().synchronize()
        
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
        UINavigationBar.appearance().barTintColor = UIColor.orangeColor()//UIColor(hex: 0xe67e22)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(), NSFontAttributeName: UIFont.systemFontOfSize(18)]
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
        resetBadgeCount()
    }
    
    func resetBadgeCount()
    {
        if UIApplication.sharedApplication().applicationIconBadgeNumber != 0
        {
            if let emailIdValue = self.userProfile?.first?.emailId {
                wsManager.resetBagdeCount(emailIdValue)
            }
        }
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

