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
        
        let first = Section(title: " ", objects: ["Rate this app", "Invite friends"], imageIcon: [UIImage(named: "more-rate.png")!, UIImage(named: "more-inviteFriends.png")!])
        let second = Section(title: " ", objects: ["Glossary"], imageIcon: [UIImage(named: "more-glossary.png")!])
        let third = Section(title: " ", objects: ["Send us feedback", "Legal"], imageIcon: [UIImage(named: "more-feedback.png")!, UIImage(named: "more-legal.png")!])
        let fourth = Section(title: " ", objects: ["Remove Ads"], imageIcon: [UIImage(named: "more-ads.png")!])
        
        sectionsArray.append(first)
        sectionsArray.append(second)
        sectionsArray.append(third)
        
        let defaults = UserDefaults.standard

        if !defaults.bool(forKey: "removeAds") {
            sectionsArray.append(fourth)
        }
        
        return sectionsArray
        
    }
}
