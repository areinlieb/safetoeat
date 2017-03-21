//
//  FoodDetailViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/9/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData
import Parse

class FoodDetailViewController: UIViewController {
    
    @IBOutlet var foodLabel: UILabel!
    
    var food = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodLabel.text = food
        addToRecent(recentFood: foodLabel.text!) //adds food item to to recent searches
        
    }

    func addToRecent(recentFood: String) {
       
        //add to core data
        let requestFood: NSFetchRequest<Recent> = Recent.fetchRequest()
        requestFood.returnsObjectsAsFaults = false
        
        do {
            
            let foodResults = try DatabaseController.getContext().fetch(requestFood)
            
            if foodResults.count > 0 {
                
                for result in foodResults as [Recent] {
                    
                    if let foodType = result.value(forKey: "foodName") as? String {
                        
                        if foodType == recentFood {
                            DatabaseController.getContext().delete(result)
                        }
                    }
                }
            }
            
            let newFood = NSEntityDescription.insertNewObject(forEntityName: "Recent", into: DatabaseController.getContext()) as! Recent
            newFood.foodName = recentFood
            newFood.timeAdded = NSDate()
            
            DatabaseController.saveContext()
            
        } catch {
            print("Couldn't fetch results")
        }
        
        
        //add to parse
        if let currentUser = PFUser.current() {
            
            currentUser.add(recentFood, forKey: "recentSearches")
            currentUser.saveInBackground()
            
        }
        
        
    }
    
    @IBAction func addToFavorites(_ sender: Any) {
        
        //add to core data
        var recordFound = false
        
        let requestFood: NSFetchRequest<Favorites> = Favorites.fetchRequest()
        requestFood.returnsObjectsAsFaults = false
        
        do {
            
            let foodResults = try DatabaseController.getContext().fetch(requestFood)
            
            if foodResults.count > 0 {
                
                for result in foodResults as [Favorites] {
                    
                    if let foodType = result.value(forKey: "foodName") as? String {
                        
                        if foodType == foodLabel.text! {
                            recordFound = true
                        }
                    }
                }
            }
            
            if !recordFound {
            
                let newFood = NSEntityDescription.insertNewObject(forEntityName: "Favorites", into: DatabaseController.getContext()) as! Favorites
                newFood.foodName = foodLabel.text!
                newFood.timeAdded = NSDate()

                DatabaseController.saveContext()
                
            }
            
        } catch {
            print("Couldn't fetch results")
        }
                
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
