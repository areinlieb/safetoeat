//
//  MoreSections.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

struct Section {
    
    var heading : String
    var items : [String]
    
    init(title: String, objects : [String]) {
        
        heading = title
        items = objects
    }
    
}
