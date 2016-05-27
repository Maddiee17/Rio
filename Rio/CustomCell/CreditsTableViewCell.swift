//
//  CreditsTableViewCell.swift
//  Olympifier
//
//  Created by Madhur Mohta on 28/05/2016.
//  Copyright © 2016 Pearson_3. All rights reserved.
//

import UIKit

class CreditsTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
