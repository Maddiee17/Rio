//
//  PopoverViewController.swift
//  Rio
//
//  Created by Madhur Mohta on 06/04/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

protocol reminderCellDelegate{
    
    func reminderAdded(forCell:EventCell)
    func reloadTableView()
}

class PopoverViewController: UIViewController {

    @IBOutlet weak var reminderSwitch: UISwitch!
    var manager = WSManager.sharedInstance
    var selectedEventModel : RioEventModel?
    var sourceView : EventCell? = nil
    var delegate : reminderCellDelegate?
    var selectedIndexPath : NSIndexPath?
    var dataBaseInteractor = RioDatabaseInteractor()
    @IBOutlet weak var titleLabel : UILabel?
    var firstTime = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(selectedIndexPath)
       sourceView = self.popoverPresentationController?.sourceView as? EventCell
        if sourceView?.notificationButton.tag == 1 {
            self.titleLabel?.text = "Add Reminder"
        }
        else{
            self.titleLabel?.text = "Remove Reminder"
        }
        
        setupObservers()
    }
    
    func setupObservers()
    {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PopoverViewController.reminderAddedSuccessfully), name: "reminderAddedSuccess", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PopoverViewController.reminderAddedFailed), name: "reminderAddedFailure", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(PopoverViewController.reminderAddedSuccessfully), name: "reminderRemovedSuccess", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PopoverViewController.reminderRemoveFailed), name: "removeReminderFailure", object: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reminderAddedSuccess", object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reminderAddedFailure", object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "reminderRemovedSuccess", object: nil)
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: "removeReminderFailure", object: nil)
    }

    
    @IBAction func addReminderSwitch(sender: AnyObject)
    {
        if Reachability.isConnectedToNetwork() {
            
            if !firstTime {
                firstTime = true
            if self.sourceView?.notificationButton.tag == 1 {
                
                sourceView?.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
                let selectedEventModel = manager.notificationButtonTappedModel
                let operation = AddReminderOperation(eventModel: selectedEventModel!, indexPath: selectedIndexPath!,completionBlock: {()-> Void in
                
                    self.sourceView?.hideLoadingIndicator();
                    self.reminderAddedSuccessfully();
                    
                
                })
                self.sourceView?.showLoadingIndicator();
                RioRootModel.sharedInstance.addRemoveReminderQueue.addOperation(operation)
                
                
                
            }
            else{
                sourceView?.notificationButton.setImage(UIImage(named: "ico-bell"), forState: .Normal)
                let selectedEventModel = manager.notificationButtonTappedModel
                dataBaseInteractor.getReminderId((selectedEventModel?.Sno)!, successBlock: { (reminderId) in
                    let operation = RemoveReminderOperation(reminderId: reminderId, serialNo: (selectedEventModel?.Sno)!, indexpath: self.selectedIndexPath!,completionBlock: {()-> Void in
                        
                        self.sourceView?.hideLoadingIndicator();
                        self.reminderAddedSuccessfully()
                        
                        
                    })
                    
                    self.sourceView?.showLoadingIndicator();
                    RioRootModel.sharedInstance.addRemoveReminderQueue.addOperation(operation)
                })
            }
            
                
            }
        }
    }
    
    
    func reminderAddedSuccessfully()
    {
        let userInfoDict = ["cell":self.sourceView as! AnyObject, "type": String(format : "%d",(sourceView?.notificationButton.tag)!)]
        NSNotificationCenter.defaultCenter().postNotificationName("refreshTable", object: nil, userInfo:userInfoDict)
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
