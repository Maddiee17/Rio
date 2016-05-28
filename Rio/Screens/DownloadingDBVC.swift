//
//  DownloadingDBVC.swift
//  Rio
//
//  Created by Madhur Mohta on 22/05/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class DownloadingDBVC: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    var downloadTask: NSURLSessionDownloadTask?
    let url = NSURL(string: "http://ec2-52-37-90-104.us-west-2.compute.amazonaws.com/olympics-scheduler/sqlfile/downloadSqlFile")
    var dataBaseInteractor = RioDatabaseInteractor()
    var userProfileDownloadModel : [RioUserProfileModel]?

    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("", forHTTPHeaderField: "Accept-Encoding")
        downloadTask = downloadsSession.downloadTaskWithRequest(request)
        downloadTask!.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func localFilePathForUrl(previewUrl: String) -> NSURL? {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as NSString
        if let url = NSURL(string: previewUrl), _ = url.lastPathComponent {
            let fullPath = documentsPath.stringByAppendingPathComponent("Rio_DB.sqlite")
            return NSURL(fileURLWithPath:fullPath)
        }
        return nil
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showOnboarding()
    {
        var onboardVC : OnboardingViewController?
        
        let firstPage = OnboardingContentViewController(title: "Welcome to Olympifire - The 2016 Olympics Notifier", body: "Never miss your favourite Olympic game. Get timely reminders", image: UIImage(named: "ico-rocket"), buttonText: "") { () -> Void in
            // do something here when users press the button, like ask for location services permissions, register for push notifications, connect to social media, or finish the onboarding process
        }
        
        let secondPage = OnboardingContentViewController(title: "Be Social!!", body: "Get all the live news of \"Olympics\" from twitter. Retweet them right from here", image: UIImage(named: "ico-twitter"), buttonText: "") { () -> Void in
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
        
        onboardVC = OnboardingViewController(backgroundImage: UIImage(named: "launch.png"), contents: [firstPage, secondPage,fourthPage])
        onboardVC!.shouldFadeTransitions = true
        onboardVC!.fadePageControlOnLastPage = true
        onboardVC!.fadeSkipButtonOnLastPage = true
        onboardVC!.shouldBlurBackground = true
        
        
        let modelName = UIDevice.currentDevice().modelName

        if modelName == "iPhone 4" || modelName == "iPhone 4s" {
            
            onboardVC!.topPadding = 8
            onboardVC!.underIconPadding = 8
            onboardVC!.underTitlePadding = 8
            onboardVC!.bottomPadding = 8
            onboardVC!.underPageControlPadding = 5
            
            myString = NSMutableAttributedString(string: "Notification options for game start, 1 hour before and more. Add reminders for your favourites    ")
        }
        
        
        fourthPage.bodyLabel.attributedText = myString
        
        
        
        self.navigationController?.pushViewController(onboardVC!, animated: true)//presentViewController(onboardVC!, animated: true, completion: nil)
    }
    
    func checkForUserProfile()
    {
        dataBaseInteractor.fetchUserProfile { (results) -> Void in
            
            if(results.count > 0){
                self.userProfileDownloadModel = results
            }
        }
    }
    
    
    func insertUserProfileValues()
    {
        let userProfileModel = self.userProfileDownloadModel?.first
        self.dataBaseInteractor.insertValuesFromModel(userProfileModel!)
    }
    
    func initDataBase() {
        let objDBManager = RioDatabaseManager.sharedInstance
        objDBManager.initDatabase()
    }

}
extension DownloadingDBVC : NSURLSessionDownloadDelegate{
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        if let originalURL = downloadTask.originalRequest?.URL?.absoluteString,
            destinationURL = localFilePathForUrl(originalURL) {
            
            print(destinationURL)
            checkForUserProfile()
                let fileManager = NSFileManager.defaultManager()
                do{
                    try fileManager.removeItemAtURL(destinationURL)
                    
                    try fileManager.copyItemAtURL(location, toURL: destinationURL)
                    
                    initDataBase()
                    if self.userProfileDownloadModel?.count > 0 {
                        
                        insertUserProfileValues()
                    }
                    let isFirstLaunch = NSUserDefaults.standardUserDefaults().objectForKey("NewDBAvailableAndFirstLaunch") as!String
                    let isSubsLaunch = NSUserDefaults.standardUserDefaults().objectForKey("NewDBAvailableAndSubsLaunch") as!String
                    
                    if isFirstLaunch == "true"{
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.showOnboarding()
                        })
                    }
                    
                    if isSubsLaunch == "true" {
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            self.performSegueWithIdentifier("AfterDownload_ProfileSegue", sender: self)
                        })
                    }
                    
                    let serverDbVersion = NSUserDefaults.standardUserDefaults().objectForKey("ServerDBVersion") as! String
                    NSUserDefaults.standardUserDefaults().setObject(serverDbVersion, forKey: "DBVersion")
                    NSUserDefaults.standardUserDefaults().synchronize()

                }
                catch{
                    // Non-fatal: file probably doesn't exis
                }
        }
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        dispatch_async(dispatch_get_main_queue()) { 
            self.progressView.progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        }
        
    }
    
    
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}
