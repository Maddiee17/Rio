//
//  HomeViewController.swift
//  Rio
//
//  Created by Pearson_3 on 14/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit
import TwitterKit

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var slideShow: KASlideShow!
    @IBOutlet weak var categoriesButton : UIButton!
    
    var wsManager = WSManager.sharedInstance
    var tweetData : NSArray?
    var refreshControl : UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Live Feeds"
        KVNProgress.showWithStatus("Loading Live Feeds..")
        setUpSlideShow()
        setUpData()
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: "setUpData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl!)
    }
    
    func setUpSlideShow(){

        slideShow.delay = 3
        slideShow.transitionDuration = 1
        slideShow.transitionType = .Slide
        slideShow.imagesContentMode = .ScaleAspectFill
        slideShow.addImagesFromResources(["stripes.jpg","olympic.jpg","stadium.png"])
    }
        
    
    func setUpData()
    {
        wsManager.getRecentTweets("en", sucessBlock: { (tweets) -> Void in
            
            do{
                let results: NSDictionary  = try NSJSONSerialization.JSONObjectWithData(tweets as! NSData, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
                print(results)
                let statusArray = results.objectForKey("statuses") as! [AnyObject]
                self.tweetData = TWTRTweet.tweetsWithJSONArray(statusArray)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    KVNProgress.dismiss()
                    self.refreshControl?.endRefreshing()
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
                KVNProgress.showErrorWithStatus("Error fetching Tweets")
                print(error)
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
    
    @IBAction func menuButtonTapped(button:UIButton)
    {
        
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
