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
    var backgroundQueue = NSOperationQueue()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        

        if(NSUserDefaults.standardUserDefaults().stringForKey(kIsFirstLaunch) == nil)
        {
            NSUserDefaults.standardUserDefaults().setValue("true", forKey: kIsFirstLaunch)
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
        
        UIApplication.sharedApplication().registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Alert , .Badge, .Sound], categories: nil))
        UIApplication.sharedApplication().registerForRemoteNotifications()

        let count = UIApplication.sharedApplication().scheduledLocalNotifications
        print(count?.count)
        
        let objDBManager = RioDatabaseManager.sharedInstance
        objDBManager.initDatabase()
        
        dataBaseInteractor.fetchUserProfile { (results) -> Void in
            
            if(results.count > 0){
                self.userProfile = results
                NSUserDefaults.standardUserDefaults().setObject(self.userProfile?.first!.userId, forKey: "userId")
                NSUserDefaults.standardUserDefaults().synchronize()
                let storyBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let userProfileVC = storyBoard.instantiateViewControllerWithIdentifier("UserProfileVC")
                self.window?.rootViewController = userProfileVC
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
        
//        let twitter = STTwitterAPI(appOnlyWithConsumerKey: kConsumerKey, consumerSecret: kConsumerSecretKey)
//        twitter.verifyCredentialsWithUserSuccessBlock({ (response) -> Void in
//            print(response)
//            }) { (error) -> Void in
//                print(error)
//        }
        Fabric.with([Twitter.self])
        customizeNavigationBar()
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation) || GIDSignIn.sharedInstance().handleURL(url,
            sourceApplication: sourceApplication,
            annotation: annotation)
        
    }
    
//    func application(application: UIApplication,
//        openURL url: NSURL, options: [String: AnyObject]) -> Bool {
//            return GIDSignIn.sharedInstance().handleURL(url,
//                sourceApplication: options[UIApplicationOpenURLOptionsSourceApplicationKey] as? String,
//                annotation: options[UIApplicationOpenURLOptionsAnnotationKey])
//    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let deviceTokenStr = convertDeviceTokenToString(deviceToken)
        
        NSUserDefaults.standardUserDefaults().setObject(deviceTokenStr, forKey: "notificationId")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if let emailIdValue = self.userProfile?.first?.emailId  {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                self.wsManager.updateDeviceToken(deviceTokenStr, email: emailIdValue)
            }

        }
        
        print(deviceTokenStr)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let alertController = UIAlertController(title: "Received Notification", message: "Blah Blah", preferredStyle: .Alert)
        let closeAction: UIAlertAction = UIAlertAction(title: "Close", style: .Cancel) { action -> Void in
        }
        alertController.addAction(closeAction)
        let viewController: UIViewController = (self.window?.rootViewController)!
        viewController.presentViewController(alertController, animated: true, completion: nil)

    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print(error.description)
    }
    
    private func convertDeviceTokenToString(deviceToken:NSData) -> String {
        
        let deviceTokenStr = deviceToken.description.componentsSeparatedByCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet).joinWithSeparator("")

        return deviceTokenStr
    }

    func customizeNavigationBar() {
        UINavigationBar.appearance().barTintColor = UIColor(hex: 0xe67e22)
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
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

