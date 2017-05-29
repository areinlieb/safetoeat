//
//  FavoriteTableViewCell.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 5/29/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet var foodLabel: UILabel!
    @IBOutlet var safetyIcon: UIImageView!
    @IBOutlet var safetyDescription: UILabel!
    @IBOutlet var categoryIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
