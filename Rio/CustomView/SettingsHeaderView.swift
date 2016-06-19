//
//  SettingsHeaderView.swift
//  Olympifier
//
//  Created by Madhur Mohta on 10/06/2016.
//  Copyright © 2016 Madhur Mohta. All rights reserved.
//

import UIKit

class SettingsHeaderView: UIView {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func awakeFromNib() {
        self.profileImage.layer.cornerRadius = 25.0
        self.profileImage.layer.borderColor = UIColor.darkGrayColor().CGColor
        self.profileImage.clipsToBounds = true
    }

}
