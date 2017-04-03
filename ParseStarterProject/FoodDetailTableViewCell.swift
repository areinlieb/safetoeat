//
//  FoodDetailTableViewCell.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/27/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class FoodDetailTableViewCell: UITableViewCell {

    @IBOutlet var descriptionText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
