//
//  RecipeCategoryFilterTableViewCell.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 7/3/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class RecipeCategoryFilterTableViewCell: UITableViewCell {

    @IBOutlet var categoryIcon: UIImageView!
    @IBOutlet var categoryLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
