//
//  MoreTableViewCell.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/23/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {

    @IBOutlet var moreLabel: UILabel!
    @IBOutlet var moreIcon: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(self.imageView?.image != nil){
            
            let imageViewFrame = self.imageView?.frame
            
            self.imageView?.contentMode = .scaleAspectFit
            self.imageView?.clipsToBounds = true
            //self.imageView?.frame = CGRectMake((imageViewFrame?.origin.x)!,(imageViewFrame?.origin.y)! + 1,40,40)
            self.imageView?.frame = CGRect(x: (imageViewFrame?.origin.x)!, y: (imageViewFrame?.height)! / 2 - 17, width: 35, height: 35)
            
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
