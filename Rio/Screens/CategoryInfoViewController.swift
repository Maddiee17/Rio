//
//  CategoryInfoViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 19/05/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class CategoryInfoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var subCategoryModel : RioSubCategoryModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tblView =  UIView(frame: CGRectZero)
        self.tableView.tableFooterView = tblView
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.title = subCategoryModel?.Category
    }

    @IBAction func closeBtnTapped(sender: AnyObject)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("subcategorycell") as! SubCategoryTableViewCell
        
            cell.userInteractionEnabled = false
            cell.accessoryType = .None
            cell.separatorInset = UIEdgeInsets(top: 0, left: 10000, bottom: 0,right: 0)
            switch indexPath.row {
            case 0:
                cell.titleLabel.attributedText = RioUtilities.sharedInstance.getAttributedString("AIM OF THE GAME", description: (subCategoryModel?.Aim)!)//String(format: "Aim : %@", (subCategoryModelLocal?.Aim)!)
            case 1:
                cell.titleLabel.attributedText = RioUtilities.sharedInstance.getAttributedString("WHY SHOULD YOU WATCH THIS", description: (subCategoryModel?.Why)!)            case 2:
                cell.titleLabel.attributedText = RioUtilities.sharedInstance.getAttributedString("OLYMPIC DEBUT", description: (subCategoryModel?.Debut)!)
            case 3:
                cell.titleLabel.attributedText = RioUtilities.sharedInstance.getAttributedString("TOP MEDALIST", description: (subCategoryModel?.Top)!)
            default:
                break
            }
        return cell
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        return 60
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
