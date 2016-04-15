//
//  IndusNotificationCell.swift
//  Indus
//
//  Created by Pearson_3 on 19/01/2016.
//  Copyright © 2016 Pearson. All rights reserved.
//

import UIKit

protocol notificationCellDelegate
{
    func showAlertForDownloadOverCellular(downloadOverCellularSwitch: UISwitch)
}
/**
 
 Customizing the uitableview cell for the notification cell
 
 */


class IndusNotificationCell: UITableViewCell {

    @IBOutlet weak var downloadOverCellularSwitch: UISwitch!
    var delegate : notificationCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if(NSUserDefaults.standardUserDefaults().stringForKey(kDownloadOverCellular) == nil){
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDownloadOverCellular)
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func DownloadOverCellularSwitchValueChanged(sender: UISwitch)
    {
        if(sender.on == true)
        {
            delegate?.showAlertForDownloadOverCellular(sender)
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: kDownloadOverCellular)
        }
    }
}
