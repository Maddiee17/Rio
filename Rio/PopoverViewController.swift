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
}

class PopoverViewController: UIViewController {

    @IBOutlet weak var reminderSwitch: UISwitch!
    var manager = WSManager.sharedInstance
    var selectedEventModel : RioEventModel?
    var sourceView : EventCell? = nil
    var delegate : reminderCellDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       sourceView = self.popoverPresentationController?.sourceView as! EventCell
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addReminderSwitch(sender: AnyObject)
    {
        sourceView?.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
        let selectedEventModel = manager.notificationButtonTappedModel
        let operation = AddReminderOperation(eventModel: selectedEventModel!)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { 
            RioBaseOperation(addReminderOperation: operation)
        }
        self.delegate?.reminderAdded(sourceView!)
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
