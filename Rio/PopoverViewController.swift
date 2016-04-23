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
    var dataBaseInteractor = RioDatabaseInteractor()
    @IBOutlet weak var titleLabel : UILabel?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       sourceView = self.popoverPresentationController?.sourceView as? EventCell
        if sourceView?.notificationButton.tag == 1 {
            self.titleLabel?.text = "Add Reminder"
        }
        else{
            self.titleLabel?.text = "Remove Reminder"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addReminderSwitch(sender: AnyObject)
    {
        if self.sourceView?.notificationButton.tag == 1 {
            
            sourceView?.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
            let selectedEventModel = manager.notificationButtonTappedModel
            let operation = AddReminderOperation(eventModel: selectedEventModel!)
            (UIApplication.sharedApplication().delegate as! AppDelegate).backgroundQueue.addOperation(operation)
        }
        else{
            sourceView?.notificationButton.setImage(UIImage(named: "ico-bell"), forState: .Normal)
            let selectedEventModel = manager.notificationButtonTappedModel
            dataBaseInteractor.getReminderId((selectedEventModel?.Sno)!, successBlock: { (reminderId) in
                let reminderId = reminderId.componentsSeparatedByString("+")[0]
                print(reminderId)
                let operation = RemoveReminderOperation(reminderId: reminderId, serialNo: (selectedEventModel?.Sno)!)
                (UIApplication.sharedApplication().delegate as! AppDelegate).backgroundQueue.addOperation(operation)
            })

        }
        let userInfoDict = ["cell":self.sourceView as! AnyObject, "type": String(format : "%d",(sourceView?.notificationButton.tag)!)]
        NSNotificationCenter.defaultCenter().postNotificationName("refreshTable", object: nil, userInfo:userInfoDict)
        self.removeFromParentViewController()
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
