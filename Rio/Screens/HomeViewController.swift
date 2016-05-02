//
//  HomeViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 14/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit
import TwitterKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slideShow: KASlideShow!
    @IBOutlet weak var categoriesButton : UIButton!
    var retryCount = 0

    var wsManager = WSManager.sharedInstance
    var tweetData : NSArray?
    var refreshControl : UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Live Feeds"
        setupLeftMenuButton()
//        setUpSlideShow()
        setUpData()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(HomeViewController.setUpData), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
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
    }
    
    func setupLeftMenuButton() {
        let leftDrawerButton = MMDrawerBarButtonItem(target: self, action: #selector(HomeViewController.leftDrawerButtonPress(_:)))
        self.navigationItem.leftBarButtonItem = leftDrawerButton
    }
    
    func leftDrawerButtonPress(leftDrawerButtonPress: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(.Left, animated: true, completion: { _ in })
    }
    
    func setUpData()
    {
        if Reachability.isConnectedToNetwork() {
            KVNProgress.showWithStatus("Loading Live Feeds..")
            wsManager.getRecentTweets("en", sucessBlock: { (tweets) -> Void in
                
                do{
                    let results: NSDictionary  = try NSJSONSerialization.JSONObjectWithData(tweets as! NSData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                    print(results)
                    let statusArray = results.objectForKey("statuses") as! [AnyObject]
                    self.tweetData = TWTRTweet.tweetsWithJSONArray(statusArray)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        KVNProgress.dismiss()
                        self.refreshControl?.endRefreshing()
                        self.setUpSlideShow()
                        self.slideShow.start()
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                    })
                }
                catch {
                    KVNProgress.showErrorWithStatus("Error fetching Tweets")
                    print(error)
                }
                
            }) { (error) -> Void in
                self.retryCount += 1
                if self.retryCount < 5 {
                    KVNProgress.showWithStatus("Retrying fetching Tweets")
                    self.setUpData()
                }
                else {
                    KVNProgress.showErrorWithStatus("Error fetching Tweets")
                }
                print(error)
            }
        }
        else {
            RioUtilities.sharedInstance.displayAlertView("Network Error".localized, messageString: "Network Error Message".localized)
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
        
        self.mm_drawerController.centerViewController = segue.destinationViewController

    }

}
