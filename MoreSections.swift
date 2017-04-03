//
//  MoreSections.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

struct Section {
    
    var heading : String
    var items : [String]
    var icon : [UIImage]
    
    init(title: String, objects : [String], imageIcon: [UIImage]) {
        
        heading = title
        items = objects
        icon = imageIcon
    }
    
}
