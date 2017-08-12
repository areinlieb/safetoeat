//
//  LoadData.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 8/11/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import Foundation
import CoreData
import Parse

class LoadData {
    
    class func loadFood() {
        
        let defaults = UserDefaults.standard
        
        let lastUpdateDate = defaults.object(forKey: "lastUpdated") as! Date
        
        let predDate = NSPredicate(format: "updatedAt > %@", lastUpdateDate as Date as CVarArg)
        
        let foodQuery = PFQuery(className: "FoodData", predicate: predDate)
        foodQuery.limit = 1000
        foodQuery.findObjectsInBackground { (objects, error) in
            
            if error == nil {
                
                if let food = objects {
                    
                    for object in food {
                        
                        if let foodItem = object["foodType"] as? String {
                            
                            //print(foodItem)
                            
                            let requestFood: NSFetchRequest<Food> = Food.fetchRequest()
                            requestFood.returnsObjectsAsFaults = false
                            requestFood.predicate = NSPredicate(format: "foodName = %@", foodItem)
                            
                            do {
                                
                                let foodResults = try DatabaseController.getContext().fetch(requestFood)
                                
                                if foodResults.count > 0 {
                                    
                                    for result in foodResults as [Food] {
                                        DatabaseController.getContext().delete(result)
                                        //print("Deleted: \(String(describing: result.value(forKey: "foodName")))")
                                    }
                                    
                                }
                            } catch {
                                print("Couldn't fetch results")
                            }
                            
                            let newFood = NSEntityDescription.insertNewObject(forEntityName: "Food", into: DatabaseController.getContext()) as! Food
                            newFood.foodName = foodItem
                            
                            if let category = object["foodCategory"] as? String {
                                newFood.foodCategory = category
                            }
                           
                            /*
                            //THIS IS NOW PROBABLY SUPERFLUOUS
                            if let updatedAt = object.updatedAt {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                let dateUpdated = dateFormatter.string(from: updatedAt)
                                newFood.dateUpdated = dateUpdated
                                //print("\(foodItem): was updated at \(String(describing: newFood.dateUpdated))")
                            } else {
                                //print("\(foodItem): no update date")
                            }
                            */
                            
                            if let safety = object["safetyDescription"] as? NSObject {
                                newFood.safetyDescription = safety
                            }
                            
                            if let safeResult = object["isSafe"] as? String {
                                newFood.isSafe = safeResult
                            }
                            
                        }
                        
                        if let updatedAt = object.updatedAt {
                            if updatedAt > defaults.object(forKey: "lastUpdated") as! Date {
/*
                                switch category {
                                    case "Veggies", "Other", "Dairy":
                                        defaults.set(updatedAt, forKey: "lastUpdated")
                                        break
                                    case "Fruit", "Grains", "Meat", "Nutrients", "Nuts, Seeds, & Legumes", "Seafood":
                                        defaults.set(updatedAt, forKey: "lastUpdated2")
                                    default: break
                                }
  */
                                defaults.set(updatedAt, forKey: "lastUpdated")
                                //let dateTemp = self.defaults.object(forKey: "lastUpdated") as! Date
                                //print("lastUpdated is now \(dateTemp)")
                            }
                        }
                        
                        DatabaseController.saveContext()
                        
                    }
                }
            }
        }
        
    }
    
    class func loadCategories() {
        
        let foodCategoryQuery = PFQuery(className: "FoodCategory")
        foodCategoryQuery.findObjectsInBackground(block: { (objects, error) in
            
            if error == nil {
                
                if let foodCategories = objects {
                    
                    for object in foodCategories {
                        
                        if let category = object["foodCategory"] as? String {
                            
                            if let imageFile = object["foodCategoryBackground"] as? PFFile {
                                
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
                                                            
                                                            if let categoryUpdatedDate = result.value(forKey: "dateUpdated") as? String {
                                                                
                                                                if let updatedAt = object.updatedAt {
                                                                    
                                                                    let dateFormatter = DateFormatter()
                                                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                                    let dateUpdated = dateFormatter.string(from: updatedAt)
                                                                    
                                                                    if categoryUpdatedDate != dateUpdated {
                                                                        DatabaseController.getContext().delete(result)
                                                                        //print("Deleted: \(String(describing: result.value(forKey: "categoryName")))")
                                                                        recordFound = false
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                //print("No Category results in Core Data fetch")
                                            }
                                        } catch {
                                            //print("Couldn't fetch results")
                                        }
                                        
                                        if !recordFound {
                                            
                                            let food = NSEntityDescription.insertNewObject(forEntityName: "Category", into: DatabaseController.getContext()) as! Category
                                            food.categoryName = category
                                            
                                            let image = UIImage(data: imageData)!
                                            let categoryImage: NSData = UIImagePNGRepresentation(image)! as NSData
                                            food.categoryImage = categoryImage
                                            
                                            if let updatedAt = object.updatedAt {
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                let dateUpdated = dateFormatter.string(from: updatedAt)
                                                food.dateUpdated = dateUpdated
                                                //print("\(category): was updated at \(String(describing: food.dateUpdated))")
                                            } else {
                                                //print("\(category): no update date")
                                            }
                                            
                                            DatabaseController.saveContext()
                                            
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            } else {
                //print("Could not retrieve food list")
            }
        })
    }
    
    class func loadRecipes() {
        
        let foodQuery = PFQuery(className: "Recipes")
        foodQuery.limit = 1000
        foodQuery.findObjectsInBackground { (objects, error) in
            
            if error == nil {
                
                if let recipes = objects {
                    
                    for object in recipes {
                        
                        if let recipeItem = object["recipeTitle"] as? String {
                            
                            var recordFound = false
                            let requestRecipe: NSFetchRequest<Recipes> = Recipes.fetchRequest()
                            requestRecipe.returnsObjectsAsFaults = false
                            
                            do {
                                
                                let recipeResults = try DatabaseController.getContext().fetch(requestRecipe)
                                
                                if recipeResults.count > 0 {
                                    
                                    for result in recipeResults as [Recipes] {
                                        
                                        if let recipeType = result.value(forKey: "recipeTitle") as? String {
                                            
                                            if recipeType == recipeItem {
                                                
                                                recordFound = true
                                                
                                                if let recipeUpdatedDate = result.value(forKey: "dateUpdated") as? String {
                                                    
                                                    if let updatedAt = object.updatedAt {
                                                        
                                                        let dateFormatter = DateFormatter()
                                                        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                        let dateUpdated = dateFormatter.string(from: updatedAt)
                                                        
                                                        if recipeUpdatedDate != dateUpdated {
                                                            DatabaseController.getContext().delete(result)
                                                            //print("Deleted: \(String(describing: result.value(forKey: "recipeTitle")))")
                                                            recordFound = false
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        
                                    }
                                } else {
                                    //print("No recipe results in Core Data fetch")
                                }
                            } catch {
                                //print("Couldn't fetch results")
                            }
                            
                            if !recordFound {
                                
                                let newRecipe = NSEntityDescription.insertNewObject(forEntityName: "Recipes", into: DatabaseController.getContext()) as! Recipes
                                newRecipe.recipeTitle = recipeItem
                                
                                if let category = object["recipeCategory"] as? String {
                                    newRecipe.recipeCategory = category
                                }
                                
                                if let url = object["recipeURL"] as? String {
                                    newRecipe.recipeURL = url
                                }
                                
                                if let urlImage = object["recipeImageURL"] as? String {
                                    newRecipe.recipeImageURL = urlImage
                                }
                                
                                if let updatedAt = object.updatedAt {
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    let dateUpdated = dateFormatter.string(from: updatedAt)
                                    newRecipe.dateUpdated = dateUpdated
                                    //print("\(recipeItem): was updated at \(String(describing: newRecipe.dateUpdated))")
                                } else {
                                    //print("\(recipeItem): no update date")
                                }
                                
                                //ADD OTHER FOOD FIELDS TO CORE DATA HERE
                                
                                if let ingredients = object["ingredients"] as? NSObject {
                                    newRecipe.ingredients = ingredients
                                }
                                
                                DatabaseController.saveContext()
                                
                            }
                        }
                    }
                }
            } else {
                //print("Could not retrieve recipe list")
            }
        }
        
    }
    
    class func loadRecipeCategories (){
        
        let foodCategoryQuery = PFQuery(className: "RecipeCategory")
        foodCategoryQuery.findObjectsInBackground(block: { (objects, error) in
            
            if error == nil {
                
                if let recipeFoodCategories = objects {
                    
                    for object in recipeFoodCategories {
                        
                        if let category = object["recipeCategory"] as? String {
                            
                            if let imageFile = object["recipeCategoryBackground"] as? PFFile {
                                
                                imageFile.getDataInBackground(block: { (data, error) in
                                    
                                    if let imageData = data {
                                        
                                        var recordFound = false
                                        let request:NSFetchRequest<RecipeCategory> = RecipeCategory.fetchRequest()
                                        request.returnsObjectsAsFaults = false
                                        
                                        do {
                                            
                                            let results = try DatabaseController.getContext().fetch(request)
                                            
                                            if results.count > 0 {
                                                
                                                for result in results as [RecipeCategory] {
                                                    
                                                    if let recipeFoodCategory = result.value(forKey: "categoryName") as? String {
                                                        
                                                        if recipeFoodCategory == category {
                                                            recordFound = true
                                                            
                                                            if let categoryUpdatedDate = result.value(forKey: "dateUpdated") as? String {
                                                                
                                                                if let updatedAt = object.updatedAt {
                                                                    
                                                                    let dateFormatter = DateFormatter()
                                                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                                    let dateUpdated = dateFormatter.string(from: updatedAt)
                                                                    
                                                                    if categoryUpdatedDate != dateUpdated {
                                                                        DatabaseController.getContext().delete(result)
                                                                        //print("Deleted: \(String(describing: result.value(forKey: "categoryName")))")
                                                                        recordFound = false
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            } else {
                                                //print("No Category results in Core Data fetch")
                                            }
                                        } catch {
                                            //print("Couldn't fetch results")
                                        }
                                        
                                        if !recordFound {
                                            
                                            let food = NSEntityDescription.insertNewObject(forEntityName: "RecipeCategory", into: DatabaseController.getContext()) as! RecipeCategory
                                            food.categoryName = category
                                            
                                            let image = UIImage(data: imageData)!
                                            let categoryImage: NSData = UIImagePNGRepresentation(image)! as NSData
                                            food.categoryImage = categoryImage
                                            
                                            if let updatedAt = object.updatedAt {
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                                let dateUpdated = dateFormatter.string(from: updatedAt)
                                                food.dateUpdated = dateUpdated
                                                //print("\(category): was updated at \(String(describing: food.dateUpdated))")
                                            } else {
                                                //print("\(category): no update date")
                                            }
                                            
                                            DatabaseController.saveContext()
                                            
                                        }
                                    }
                                })
                            }
                        }
                    }
                }
            } else {
                //print("Could not retrieve food list")
            }
        })
        
    }
    
}

/*
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
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Food] {
 print("result are \(result)")
 }
 } else {
 //print("Food: Core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
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
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Category] {
 //print("result are \(result)")
 }
 } else {
 //print("Category: Core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
 }
 
 }
 
 func deleteCoreDataRecipes() {
 
 let fetchRequest:NSFetchRequest<Recipes> = Recipes.fetchRequest()
 
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Recipes] {
 DatabaseController.getContext().delete(result)
 }
 }
 } catch {
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Recipes] {
 //print("result are \(result)")
 }
 } else {
 //print("Recipes: Core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
 }
 
 }
 
 func deleteCoreDataRecipeCategories() {
 
 let fetchRequest:NSFetchRequest<RecipeCategory> = RecipeCategory.fetchRequest()
 
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [RecipeCategory] {
 DatabaseController.getContext().delete(result)
 }
 }
 } catch {
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [RecipeCategory] {
 //print("result are \(result)")
 }
 } else {
 //print("RecipeCategory: Core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
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
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Favorites] {
 //print("result are \(result)")
 }
 } else {
 //print("Favorites: core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
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
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Searches] {
 //print("result are \(result)")
 }
 } else {
 //print("Searches: core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
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
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [Recent] {
 //print("result are \(result)")
 }
 } else {
 //print("Recent: core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
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
 //print("Couldn't fetch results")
 }
 
 //checks if core data is empty
 do {
 
 let results = try DatabaseController.getContext().fetch(fetchRequest)
 
 if results.count > 0 {
 for result in results as [User] {
 //print("result are \(result)")
 }
 } else {
 //print("User Email: core data is empty")
 }
 } catch {
 //print("Couldn't fetch results")
 }
 
 }
 */
