//
//  SectionsData.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class SectionsData {
    
    func getSectionsFromData() -> [Section] {
    
        var sectionsArray = [Section]()
        
        let first = Section(title: " ", objects: ["Rate app", "Invite friends"], imageIcon: [UIImage(named: "more-rate.png")!, UIImage(named: "more-inviteFriends.png")!])
        let second = Section(title: " ", objects: ["Glossary"], imageIcon: [UIImage(named: "more-glossary.png")!])
        let third = Section(title: " ", objects: ["Request to add food","Send us feedback", "Legal"], imageIcon: [UIImage(named: "more-requestAdd.png")!, UIImage(named: "more-feedback.png")!, UIImage(named: "more-legal.png")!])
        
        sectionsArray.append(first)
        sectionsArray.append(second)
        sectionsArray.append(third)
        
        return sectionsArray
        
    }
}
