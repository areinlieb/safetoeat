//
//  SectionsData.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

class SectionsData {
    
    func getSectionsFromData() -> [Section] {
    
        var sectionsArray = [Section]()
        
        let first = Section(title: "Logout", objects: ["Logout"])
        let second = Section(title: "More", objects: ["Blog", "Glossary", "Rate App", "Request to add food","Send Us Feedback", "Legal"])
    
        sectionsArray.append(first)
        sectionsArray.append(second)
        
        return sectionsArray
        
    }
}
