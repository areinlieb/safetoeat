//
//  CoreDataViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/14/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreData

class CoreDataViewController: UIViewController {

    @IBOutlet var backgroundImage: UIImageView!
    
    var counter = 0
    var timer = Timer()
    
    var foodCategoryTypes = [String]()
    var foodCategoryImages = [UIImage]()

    
    func animate() {
        
        backgroundImage.image = UIImage(named: "frame_\(counter).png")
        counter += 1
        
        if counter == 9 {

            let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
            
            //checks if email has been entered
            do {
                
                let results = try DatabaseController.getContext().fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Welcome")
                        self.present(viewController, animated: true, completion: nil)
                    })
                }
            } catch {
                print("Couldn't fetch results")
            }
       }
        
    }
 
    override func viewDidLoad() {
 
        super.viewDidLoad()
/*
        deleteCoreDataFood()
        deleteCoreDataCategories()
        deleteCoreDataFavorites()
        deleteCoreDataSearches()
        deleteCoreDataRecent()
*/
        deleteCoreDataEmail()

        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(CoreDataViewController.animate), userInfo: nil, repeats: true)
        animate()
        
        //load data from parse into core data
        loadCategories()
        loadFood()
        
    }
    
    func loadCategories() {
        
        let foodCategoryQuery = PFQuery(className: "FoodCategory")
        foodCategoryQuery.findObjectsInBackground(block: { (objects, error) in
            
            if error == nil {
                
                if let foodCategories = objects {
                    
                    for object in foodCategories {
                        
                        if let category = object["foodCategory"] as? String {
                            
                            if let imageFile = object["foodCategoryIcons"] as? PFFile {
                                
                                imageFile.getDataInBackground(block: { (data, error) in
                                    
                                    if let imageData = data {
                                        
                                        var recordFound = false
                                        let request:NSFetchRequest<Category> = Category.fetchRequest()
                                        request.returnsObjectsAsFaults = false
                                        
                                        do {
                                            
                                            let results = try DatabaseController.getContext().fetch(request)
                                            
                                            if results.count > 0 {
                                                
                                                for result in results as [Category] {
                                                    
                                                    if let foodCategory = result.value(forKey: "categoryName") as? String {
                                                        
                                                        if foodCategory == category {
                                                            recordFound = true
                                                        }
                                                    }
                                                }
                                            } else {
                                                print("No Category results in Core Data fetch")
                                            }
                                        } catch {
                                            print("Couldn't fetch results")
                                        }
                                        
                                        if !recordFound {
                                            
                                            let food = NSEntityDescription.insertNewObject(forEntityName: "Category", into: DatabaseController.getContext()) as! Category
                                            food.categoryName = category
                                            
                                            let image = UIImage(data: imageData)!
                                            let categoryImage: NSData = UIImagePNGRepresentation(image)! as NSData
                                            food.categoryIcon = categoryImage
                                            
                                            DatabaseController.saveContext()
                                            
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            } else {
                print("Could not retrieve food list") //CHANGE THIS TO DISPLAY AN ALERT
            }
        })
    }
    
    func loadFood() {
        
        let foodQuery = PFQuery(className: "FoodData")
        foodQuery.limit = 500
        foodQuery.findObjectsInBackground { (objects, error) in
            
            if error == nil {
                
                if let food = objects {
                    
                    for object in food {
                        
                        if let foodItem = object["foodType"] as? String {
                            
                            var recordFound = false
                            let requestFood: NSFetchRequest<Food> = Food.fetchRequest()
                            requestFood.returnsObjectsAsFaults = false
                            
                            do {
                                
                                let foodResults = try DatabaseController.getContext().fetch(requestFood)
                                
                                if foodResults.count > 0 {
                                    
                                    for result in foodResults as [Food] {
                                        
                                        if let foodType = result.value(forKey: "foodName") as? String {
                                            
                                            if foodType == foodItem {
                                                
                                                recordFound = true
                                                
                                                if let foodUpdatedDate = result.value(forKey: "dateUpdated") as? String {
                                                    
                                                    if let updatedAt = object.updatedAt {
                                                        
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                        let dateUpdated = dateFormatter.string(from: updatedAt)
                                                        
                                                        if foodUpdatedDate != dateUpdated {
                                                            DatabaseController.getContext().delete(result)
                                                            print("Deleted: \(String(describing: result.value(forKey: "foodName")))")
                                                            recordFound = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                } else {
                                    print("No food results in Core Data fetch")
                                }
                            } catch {
                                print("Couldn't fetch results")
                            }
                            
                            if !recordFound {
                                
                                let newFood = NSEntityDescription.insertNewObject(forEntityName: "Food", into: DatabaseController.getContext()) as! Food
                                newFood.foodName = foodItem
                                
                                if let category = object["foodCategory"] as? String {
                                    newFood.foodCategory = category
                                }
                                
                                if let updatedAt = object.updatedAt {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    let dateUpdated = dateFormatter.string(from: updatedAt)
                                    newFood.dateUpdated = dateUpdated
                                    print("\(foodItem): was updated at \(String(describing: newFood.dateUpdated))")
                                } else {
                                    print("\(foodItem): no update date")
                                }
                                
                                //ADD OTHER FOOD FIELDS TO CORE DATA HERE
                                
                                if let safety = object["safetyDescription"] as? NSObject {
                                    newFood.safetyDescription = safety
                                }

                                if let safeResult = object["isSafe"] as? String {
                                    newFood.isSafe = safeResult
                                }
                                
                                DatabaseController.saveContext()
                                
                            }
                        }
                    }
                }
            } else {
                print("Could not retrieve food list") //CHANGE THIS TO DISPLAY AN ALERT?
            }
        }

    }
    
    func deleteCoreDataFood() {
        
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Food] {
                    DatabaseController.getContext().delete(result)
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
 
        //checks if core data is empty
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Food] {
                    print("result are \(result)")
                }
            } else {
                print("Food: Core data is empty")
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func deleteCoreDataCategories() {
        
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Category] {
                    DatabaseController.getContext().delete(result)
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
        //checks if core data is empty
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Category] {
                    print("result are \(result)")
                }
            } else {
                print("Category: Core data is empty")
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func deleteCoreDataFavorites() {
        
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Favorites] {
                    DatabaseController.getContext().delete(result)
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
        //checks if core data is empty
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Favorites] {
                    print("result are \(result)")
                }
            } else {
                print("Favorites: core data is empty")
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func deleteCoreDataSearches() {
        
        let fetchRequest:NSFetchRequest<Searches> = Searches.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Searches] {
                    DatabaseController.getContext().delete(result)
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
        //checks if core data is empty
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Searches] {
                    print("result are \(result)")
                }
            } else {
                print("Searches: core data is empty")
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }

    func deleteCoreDataRecent() {
        
        let fetchRequest:NSFetchRequest<Recent> = Recent.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Recent] {
                    DatabaseController.getContext().delete(result)
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
        //checks if core data is empty
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Recent] {
                    print("result are \(result)")
                }
            } else {
                print("Recent: core data is empty")
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func deleteCoreDataEmail() {
        
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [User] {
                    DatabaseController.getContext().delete(result)
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
        //checks if core data is empty
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [User] {
                    print("result are \(result)")
                }
            } else {
                print("User Email: core data is empty")
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
