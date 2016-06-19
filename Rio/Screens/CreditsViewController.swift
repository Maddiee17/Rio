//
//  CreditsViewController.swift
//  Olympifier
//
//  Created by Madhur Mohta on 27/05/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class CreditsViewController: UITableViewController,UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        self.title = "Credits"
        
        self.tableView.tableFooterView = UIView(frame : CGRectZero)
        
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil) {
            self.navigationController!.interactivePopGestureRecognizer!.enabled = true;
            self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        }

        setUpLeftBarButton()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLeftBarButton() {
        
        let btnBackImage = UIImage(named: "ico-left-arrow")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let btnBack = UIBarButtonItem(image: btnBackImage, style: .Plain, target: self, action: #selector(CreditsViewController.backButtonTapped(_:)))
        self.navigationItem.leftBarButtonItem = btnBack
    }
    
    func backButtonTapped(sender:AnyObject)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }



    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.mm_drawerController.openDrawerGestureModeMask = .None
        self.mm_drawerController.closeDrawerGestureModeMask = .None
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool
    {
        if (self.navigationController?.respondsToSelector(Selector("interactivePopGestureRecognizer")) != nil && gestureRecognizer == self.navigationController?.interactivePopGestureRecognizer) {
            return true
        }
        return false
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("credits", forIndexPath: indexPath) as! CreditsTableViewCell

        // Configure the cell...
        
        switch indexPath.row {
        case 0:
            cell.cellImageView?.image = UIImage(named: "oo.jpg")
            cell.textView?.attributedText = addTruncToken()
            
            default:
            break
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 200
    }
    
    func addTruncToken() -> NSMutableAttributedString
    {
        
        let license = NSMutableAttributedString(string: " - By Chen Feng is licensed under CC BY 2.0")
        let url = "http://creativecommons.org/licenses/by/2.0/"
        
        let range = NSMakeRange(0, license.length)
        license.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13), range: range)
        license.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: range)
        license.addAttribute(NSLinkAttributeName, value: url, range: range)

        
        
        let author = NSMutableAttributedString(string: "Rio de Janeiro 2016 Olympic Games visual identity revealed rio 2016 olympics pictograms")
        let authorURL = NSURL(string: "https://www.flickr.com/photos/congfengchen/13306167385")
        
        let authorRange = NSMakeRange(0, author.length)
        author.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(13), range: authorRange)
        author.addAttribute(NSForegroundColorAttributeName, value: UIColor.blueColor(), range: authorRange)
        author.addAttribute(NSLinkAttributeName, value: authorURL!, range: authorRange)
        
        author.appendAttributedString(license)
        
        return author
    }

    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
