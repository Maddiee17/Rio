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
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView!
    var event : String?
    
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
    
    func initWithEventObject(eventObj:RioEventModel, notificationEnabledCell:[String], selectedEvent:String){
        event = selectedEvent
        self.eventTime.text = RioUtilities.sharedInstance.getTrimmedTime(eventObj.StartTime!)
        self.eventVenue.text = RioUtilities.sharedInstance.getVenueName(eventObj.VenueName!)
        self.eventMedals.text = eventObj.Medal
        if self.eventMedals.text == "Yes" {
            self.medalImageView.image = UIImage(named: "ico-medal")
        }
        else{
            self.medalImageView.image = UIImage(named: "ico-nomedal")
        }
        self.eventDate.text = RioUtilities.sharedInstance.getTrimmedDate(eventObj.Date!)
        
        self.eventName.text = eventObj.DescriptionLong?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if (notificationEnabledCell.contains(eventObj.Sno!)) {
            self.notificationButton.setImage(UIImage(named: "ico-bell-selected"), forState: .Normal)
            self.notificationButton.tag = 2
        }
        else{
            self.notificationButton.setImage(UIImage(named: "ico-bell"), forState: .Normal)
            self.notificationButton.tag = 1
        }
        self.eventName.sizeToFit()

        self.medalImageView.image = self.medalImageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.medalImageView.tintColor = UIColor(hex :0xD21F69)
        self.notificationButton.tintColor = UIColor(hex : 0xD21F69)
        hideLoadingIndicator();
        

    }
    
    func hideLoadingIndicator(){
    
        self.loadingIndicatorView.stopAnimating()
        self.loadingIndicatorView.hidden = true
        self.notificationButton.hidden = false
    
    }
    
    func showLoadingIndicator(){
    
        self.notificationButton.hidden = true
        self.loadingIndicatorView.hidden = false
        self.loadingIndicatorView.startAnimating()
    
    }
    
}
