//
//  EventCell.swift
//  Rio
//
//  Created by Madhur Mohta on 12/03/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

protocol EventCellDelegate{
    
    func notificationButtonTapped(forCell:EventCell)
}

class EventCell: UITableViewCell {

    var delegate : EventCellDelegate?
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventDate: UILabel!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventMedals: UILabel!
    @IBOutlet weak var eventVenue: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var medalImageView: UIImageView!
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
