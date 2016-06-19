//
//  HomeViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 14/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit
import TwitterKit

class HomeViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slideShow: KASlideShow!
//    @IBOutlet weak var categoriesButton : UIButton!
    var categoriesButton : UIButton!
    var retryCount = 0

    var wsManager = WSManager.sharedInstance
    var tweetData : NSArray?
    var refreshControl : UIRefreshControl?
    var hideLoadingIndicator = false
    var lastOffset : CGPoint?
    var isPushedFromNotification = false
    var eventForNotification : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Live Feeds"
        setupLeftMenuButton()
        addButton()


        if RioRootModel.sharedInstance.emergencyTweetData == nil && RioRootModel.sharedInstance.isPushedFromNotification == false
        {
            setUpData()
        }
        else {
            self.tweetData = RioRootModel.sharedInstance.emergencyTweetData
            self.tableView.hidden = false
            self.tableView.reloadData()
            setUpSlideShow()
            slideShow.start()
        }
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(HomeViewController.refreshData), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
        if RioRootModel.sharedInstance.isPushedFromNotification == true
        {
            NSLog("Home VC Load View **************************")
            categoriesButtonTapped()
        }
        

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSLog("Home VC ViewWillAppear **************************")
        
        if RioRootModel.sharedInstance.emergencyTweetData != nil {
            addButton()
            self.showCategoriesButton()
        }

        self.mm_drawerController.openDrawerGestureModeMask = .All
        self.mm_drawerController.closeDrawerGestureModeMask = .All

        self.mm_drawerController.setGestureCompletionBlock { (drawer, gesture) in
            
            if self.mm_drawerController.openSide == .None{
                self.showCategoriesButton()
            }
            else{
                self.hideCategoriesButton()
            }
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.mm_drawerController.setGestureCompletionBlock(nil)

    }
    
    func addButton() {
        
        categoriesButton = UIButton(frame: CGRectMake(0, self.view.frame.size.height + 20 , self.view.frame.size.width, 44))
        categoriesButton.backgroundColor = UIColor(hex: 0xecf0f1)
        categoriesButton.setTitle("Categories", forState: .Normal)
        categoriesButton.setTitleColor(UIColor(hex: 0x2c3e50), forState: .Normal)
        categoriesButton.addTarget(self, action: #selector(HomeViewController.categoriesButtonTapped), forControlEvents: .TouchUpInside)
        categoriesButton.tag = 1
        if self.tweetData == nil {
            categoriesButton.userInteractionEnabled = false
        }
        else {
            categoriesButton.userInteractionEnabled = true
        }
        UIApplication.sharedApplication().keyWindow?.addSubview(categoriesButton)
        
        NSLog("Home VC addButton **************************")

    }
    
    //
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UIApplication.sharedApplication().keyWindow?.viewWithTag(1)?.removeFromSuperview()
    }
    
    func categoriesButtonTapped()
    {
        NSLog("Home VC CategoryButtonTapped **************************")

        UIApplication.sharedApplication().keyWindow?.viewWithTag(1)?.removeFromSuperview()
        let categoriesVC = self.storyboard?.instantiateViewControllerWithIdentifier("CategoryListViewController")
        self.mm_drawerController.centerViewController = categoriesVC
    }
    
    func setUpSlideShow(){

        slideShow.delay = 2
        slideShow.transitionDuration = 1
        slideShow.transitionType = .Fade
        slideShow.imagesContentMode = .ScaleAspectFill
        let dataArray = RioRootModel.sharedInstance.imagesURLArray
        if dataArray.count > 0
        {
            for data in dataArray {
                let image = UIImage(data: data)
                slideShow.addImage(image)
            }
        }
        NSLog("Home VC SetupSlideShow **************************")

    }
    
    func setupLeftMenuButton() {
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(HomeViewController.leftDrawerButtonPress(_:)))
        leftDrawerButton.tintColor = UIColor.darkGrayColor()
        self.navigationItem.leftBarButtonItem = leftDrawerButton
        NSLog("Home VC LeftMenuButton **************************")

    }
    
    func leftDrawerButtonPress(leftDrawerButtonPress: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: { _ in
            if self.mm_drawerController.openSide == .None{
                self.showCategoriesButton()
            }
            else{
                self.hideCategoriesButton()
            }
        })
    }
    
    func refreshData()  {
        
        hideLoadingIndicator = true
        setUpData()
    }
    
    func setUpData()
    {
        if Reachability.isConnectedToNetwork() {
            if !hideLoadingIndicator {
                KVNProgress.showWithStatus("Loading Live Feeds..")
            }
            wsManager.getRecentTweets("en", sucessBlock: { (tweets) -> Void in
                
                self.categoriesButton.userInteractionEnabled = true
                do{
                    let results: NSDictionary  = try NSJSONSerialization.JSONObjectWithData(tweets as! NSData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    print(results)
                    let statusArray = results.objectForKey("statuses") as! [AnyObject]
                    self.tweetData = TWTRTweet.tweetsWithJSONArray(statusArray)
                    RioRootModel.sharedInstance.emergencyTweetData = self.tweetData
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        KVNProgress.dismiss()
                        self.refreshControl?.endRefreshing()
                        self.setUpSlideShow()
                        self.slideShow.start()
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                        self.showCategoriesButton()
                    })
                }
                catch {
                    if !self.hideLoadingIndicator {
                        KVNProgress.showErrorWithStatus("Error fetching Tweets")
                    }
                    self.refreshControl?.endRefreshing()
                    self.categoriesButton.userInteractionEnabled = true
                    print(error)
                }
                
            }) { (error) -> Void in
                self.categoriesButton.userInteractionEnabled = true
                self.refreshControl?.endRefreshing()
                self.retryCount += 1
                if self.retryCount < 4 {
                    if !self.hideLoadingIndicator {
                        KVNProgress.showWithStatus("Retrying fetching Tweets")
                    }
                    self.setUpData()
                }
                else if(RioRootModel.sharedInstance.emergencyTweetData?.count > 0 && RioRootModel.sharedInstance.emergencyTweetData != nil)
                {
                    self.tweetData = RioRootModel.sharedInstance.emergencyTweetData
                    dispatch_async(dispatch_get_main_queue(), {
                        KVNProgress.dismiss()
                        self.tableView.reloadData()
                        self.setUpSlideShow()
                        self.slideShow.start()
                    })
                }
                else {
                    self.categoriesButton.userInteractionEnabled = true
                    KVNProgress.showErrorWithStatus("Error fetching Tweets")
                }
                print(error)
            }
        }
        else {
            displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
        }
    }
    
    func displayAlertView(titleString: String, messageString: String) {
        
        if !isAlertAlreadyDisplayed {
            let alert: UIAlertView = UIAlertView(title: titleString, message: messageString, delegate: nil, cancelButtonTitle: "OK")
            alert.show()
            isAlertAlreadyDisplayed = true
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("tweetCell") as! TWTRTweetTableViewCell
        
        let tweet = self.tweetData![indexPath.row]
        
        cell.configureWithTweet(tweet as! TWTRTweet)
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int // Default is 1 if not implemented
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if(self.tweetData?.count > 0)
        {
            return (self.tweetData?.count)!
        }
        else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        let tweet = self.tweetData![indexPath.row]
        
        let height = TWTRTweetTableViewCell.heightForTweet(tweet as! TWTRTweet, style: TWTRTweetViewStyle.Compact, width: self.view.frame.size.width, showingActions: true)
        
        return height
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        

    }
    

     func scrollViewWillBeginDragging(scrollView: UIScrollView)
     {
        hideCategoriesButton()
    }

     func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
     {
        if !decelerate && self.mm_drawerController.openSide == .None {
            showCategoriesButton()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) // called when scroll view grinds to a halt
    {
        if self.mm_drawerController.openSide == .None{
            showCategoriesButton()
        }
    }


    func hideCategoriesButton()
    {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.categoriesButton.frame = CGRectMake(0, self.view.frame.size.height + 20 + 44 , self.view.frame.size.width, 44)
            }, completion: nil)

    }
    
    func showCategoriesButton()
    {
        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.categoriesButton.frame = CGRectMake(0, self.view.frame.size.height + 20 , self.view.frame.size.width, 44)
            }, completion: nil)
    }
}
