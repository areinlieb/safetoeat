//
//  RecipesTableViewCell.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 6/27/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class RecipesTableViewCell: UITableViewCell {


    @IBOutlet var recipeTitle: UILabel!
    @IBOutlet var ingredients: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
