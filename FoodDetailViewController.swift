//
//  FoodDetailViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/9/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData

class FoodDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var babyIcon: UIImageView!
    @IBOutlet var categoryImage: UIImageView!
    
    var food = String()
    var favorites = [String()]
    var descriptionDict = [String: Array<Any>]()
    var safetyDescription = [String()]
    var safeEat = String()
    var category = String()

    override func viewDidAppear(_ animated: Bool) {
        
        loadFavoriteList()

        if favorites.contains(food) {
            setFavoriteButton(isFavorite: true)
        } else {
            setFavoriteButton(isFavorite: false)
        }
        
        navigationItem.title = food
        
        loadCategoryImage()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400

        tableView.reloadData()
    }
 
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 400

        tableView.separatorStyle = UITableViewCellSeparatorStyle.none

        loadFavoriteList()
        loadFoodDescription()
        
        

        if favorites.contains(food) {
            setFavoriteButton(isFavorite: true)
        } else {
            setFavoriteButton(isFavorite: false)
        }
        
        
        
        
        addToRecent(recentFood: food) //adds food item to to recent searches
        
    }
    
    func loadFavoriteList() {
        
        favorites.removeAll()
        
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let foodSortFavorites = NSSortDescriptor(key: "foodName", ascending: true)
        
        fetchRequest.sortDescriptors = [foodSortFavorites]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Favorites] {
                    if let foodItem = result.foodName {
                        self.favorites.append(foodItem)
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func loadFoodDescription() {

        safetyDescription.removeAll()
        
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Food] {
                    if let foodItem = result.foodName {
                        if foodItem == food {
                            if let foodDescription = result.safetyDescription as? NSArray {
                                for foodText in foodDescription {
                                    self.safetyDescription.append(foodText as! String)
                                }
                            }
                        
                            if let safe = result.isSafe {
                                self.safeEat = safe
                                
                                if safe == "safe" {
                                    babyIcon.image = UIImage(named: "smile.png")
                                } else if safe == "not safe" {
                                    babyIcon.image = UIImage(named: "frown.png")
                                } else {
                                    babyIcon.image = UIImage(named: "question.png")
                                }
                            }
                            
                            category = result.foodCategory!
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func loadCategoryImage() {
        
        //categoryImage.image = UIImageView(image: foodCategoryImages[indexPath.row])
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Category] {
                    if let categoryName = result.categoryName {
                        if category == categoryName {
                            if let categoryIcon = result.categoryIcon {
                                categoryImage.image = UIImage(data: categoryIcon as Data)
                                categoryImage.alpha = 0.5
                                categoryImage.contentMode = .scaleAspectFill
                            }
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func setFavoriteButton(isFavorite: Bool) {
        
        //add favorites button to navigation bar on right side
        let button = UIButton.init(type: .custom)

        button.frame = CGRect(x: 0, y: 0, width: 34, height: 34 )
        
        let favoriteButton = UIBarButtonItem(customView: button)
        
        if isFavorite {
            button.setImage(UIImage(named: "removeFromFavorites.png"), for: UIControlState.normal)
        } else {
            button.setImage(UIImage(named: "addToFavorites.png"), for: UIControlState.normal)
        }

        button.addTarget(self, action: #selector(FoodDetailViewController.addToFavorites), for: UIControlEvents.touchUpInside)
        self.navigationItem.rightBarButtonItem = favoriteButton
        
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
                        
                        if foodType == food {
                            
                            recordFound = true
                            removefromFavorites(favoriteToRemove: food)
                            
                        }
                    }
                }
            }
            
            if !recordFound {
            
                let newFood = NSEntityDescription.insertNewObject(forEntityName: "Favorites", into: DatabaseController.getContext()) as! Favorites
                newFood.foodName = food
                newFood.isSafe = safeEat
                newFood.safetyDescription = safetyDescription as NSObject
                newFood.foodCategory = category
                newFood.timeAdded = NSDate()

                DatabaseController.saveContext()
                            
                setFavoriteButton(isFavorite: true)
                
            }
                
        } catch {
            print("Couldn't fetch results")
        }
                
    }
    
    func removefromFavorites(favoriteToRemove: String) {
        
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Favorites] {
                    if result.foodName == favoriteToRemove {

                        DatabaseController.getContext().delete(result)
                        setFavoriteButton(isFavorite: false)

                    }
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        return safetyDescription.count
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FoodDetailTableViewCell
        
        cell.textLabel?.text = safetyDescription[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.textAlignment = .center
                
        return cell
        
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (50.0)
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 5 , height: 50))
        
        return footerView
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
