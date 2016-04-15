//
//  EventCell.swift
//  Rio
//
//  Created by Pearson_3 on 12/03/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

protocol EventCellDelegate{
    
    func notificationButtonTapped(forCell:EventCell)
}

class EventCell: UITableViewCell {

    var delegate : EventCellDelegate?
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventImage: UIImageView!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventMedals: UILabel!
    @IBOutlet weak var eventVenue: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func notificationButtonTapped(sender: AnyObject)
    {
        delegate?.notificationButtonTapped(self)
    }
}
