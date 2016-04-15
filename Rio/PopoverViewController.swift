//
//  PopoverViewController.swift
//  Rio
//
//  Created by Pearson_3 on 06/04/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class PopoverViewController: UIViewController {

    @IBOutlet weak var reminderSwitch: UISwitch!
    var manager = WSManager.sharedInstance
    var selectedEventModel : RioEventModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func addReminderSwitch(sender: AnyObject)
    {
        manager.addReminderForEvent()
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
