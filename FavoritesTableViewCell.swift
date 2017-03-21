//
//  FavoritesTableViewCell.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/9/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {
    
    @IBOutlet var foodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
