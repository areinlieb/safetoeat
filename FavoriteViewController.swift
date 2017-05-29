//
//  FavoriteViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 5/29/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData


class FavoriteViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var foodList = [String()]
    var favorites = [String()]
    var safety = [String: String]()
    var safetyDescription = [String: String]()
    
    var selectedFavorite = ""
    var deleteFavoritesIndexPath: IndexPath? = nil
    
    var backgroundView = UIImageView(image: UIImage(named: "star background.png"))
    var backgroundText = UILabel()
    
    @IBOutlet var tableView: UITableView!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            let DestViewController : FoodDetailViewController = segue.destination as! FoodDetailViewController
            
            DestViewController.food = favorites[(tableView.indexPathForSelectedRow?.row)!]
            //navigationItem.title = "Food"
            
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationItem.title = "Favorites"
        
        if favorites.count == 0 {
            setBackgroundImage(show: true)
        } else {
            setBackgroundImage(show: false)
        }
        
        //retrieve favorites list
        loadFavoriteList()
        
        tableView.reloadData()
        
        self.tableView.sendSubview(toBack: backgroundView)
        self.tableView.sendSubview(toBack: backgroundText)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.frame.size.width = 100
        backgroundView.frame.size.height = 100
        backgroundView.center = self.view.center
        backgroundView.frame.origin.y = self.view.center.y * 0.5
        
        self.tableView.sendSubview(toBack: backgroundView)
        
        backgroundText.text = "No favorite items"
        backgroundText.textColor = UIColor(red: 66.0/255.0, green: 68.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        backgroundText.contentMode = .scaleAspectFit
        
        //SIZE OF IMAGE AND TEXT SHOULD SCALE BASED ON SCREEN SIZE
        backgroundText.frame.size.width = 130
        backgroundText.frame.size.height = 20
        
        backgroundText.center = self.view.center
        backgroundText.frame.origin.y = self.view.center.y * 0.90
        
        self.tableView.sendSubview(toBack: backgroundText)
        
        //retrieve favorites list
        loadFavoriteList()
        
        tableView.reloadData()
        
    }
    /*
     func loadFoodList() {
     
     let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
     
     let foodSort = NSSortDescriptor(key: "foodName", ascending: true)
     fetchRequest.sortDescriptors = [foodSort]
     
     do {
     
     let results = try DatabaseController.getContext().fetch(fetchRequest)
     
     if results.count > 0 {
     
     foodList.removeAll()
     safety.removeAll()
     
     for result in results as [Food] {
     if let foodItem = result.foodName {
     self.foodList.append(foodItem)
     
     if let safe = result.isSafe {
     self.safety[foodItem] = safe
     } else {
     print("Couldn't get safety result for foodItem \(String(describing: result.foodName))")
     }
     
     }  else {
     print("Couldn't add foodItem \(String(describing: result.foodName))")
     }
     }
     }
     } catch {
     print("Error: \(error)")
     }
     
     }
     */
    
    func loadFavoriteList() {
        
        favorites.removeAll()
        safety.removeAll()
        safetyDescription.removeAll()
        
        
        let fetchRequest:NSFetchRequest<Favorites> = Favorites.fetchRequest()
        let foodSortFavorites = NSSortDescriptor(key: "foodName", ascending: true)
        
        fetchRequest.sortDescriptors = [foodSortFavorites]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Favorites] {
                    if let foodItem = result.foodName {
                        self.favorites.append(foodItem)
                        
                        if let safe = result.isSafe {
                            self.safety[foodItem] = safe
                        } else {
                            print("Couldn't get safety result for foodItem \(String(describing: result.foodName))")
                        }
                        
                        if let foodDescription = result.safetyDescription as? NSArray {
                            self.safetyDescription[foodItem] = foodDescription[0] as? String
                        } else {
                            print("Couldn't get safety description for foodItem \(String(describing: result.foodName))")
                        }
                        
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func setBackgroundImage(show: Bool) {
        
        if show {
            
            self.tableView.addSubview(backgroundView)
            self.tableView.addSubview(backgroundText)
            
            self.tableView.backgroundColor = UIColor(red: 227.0/255.0, green: 227.0/255.0, blue: 227.0/255.0, alpha: 1.0)
            
            self.tableView.separatorStyle = .none
            
        } else {
            
            backgroundView.removeFromSuperview()
            backgroundText.removeFromSuperview()
            
            self.tableView.separatorStyle = .singleLine
            self.tableView.backgroundColor = UIColor.white
            
        }
        
    }
    
    func getCategory (food: String) -> UIImage {
        
        var category = ""
        var categoryIcon = UIImage()
        
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Food] {
                    if let foodItem = result.foodName {
                        if food == foodItem {
                            category = result.foodCategory!
                        }
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        switch category {
        case "Dairy":
            categoryIcon = UIImage(named: "dairy.png")!
        case "Fruit":
            categoryIcon = UIImage(named: "fruit.png")!
        case "Grains":
            categoryIcon = UIImage(named: "grains.png")!
        case "Meat":
            categoryIcon = UIImage(named: "meat.png")!
        case "Nuts, Seeds, & Legumes":
            categoryIcon = UIImage(named: "nuts.png")!
        case "Other":
            categoryIcon = UIImage(named: "Other.png")!
        case "Seafood":
            categoryIcon = UIImage(named: "seafood.png")!
        case "Veggies":
            categoryIcon = UIImage(named: "vegetable.png")!
        default:
            break
        }
        
        return categoryIcon
        
    }
    
    func editButtonPressed(){
     
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FavoriteViewController.editButtonPressed))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FavoriteViewController.editButtonPressed))
        }
    }
    
    internal func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let foodToDelete = favorites[indexPath.row]
            
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            let requestFood: NSFetchRequest<Favorites> = Favorites.fetchRequest()
            requestFood.returnsObjectsAsFaults = false
            
            do {
                
                let foodResults = try DatabaseController.getContext().fetch(requestFood)
                
                if foodResults.count > 0 {
                    
                    for result in foodResults as [Favorites] {
                        
                        if let foodType = result.value(forKey: "foodName") as? String {
                            
                            if foodType == foodToDelete {
                                DatabaseController.getContext().delete(result)
                            }
                        }
                    }
                }
            } catch {
                print("Couldn't fetch results")
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.reloadData()
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if favorites.count > 0 {
            //self.navigationItem.rightBarButtonItem = self.editButtonItem
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: UIBarButtonItemStyle.plain, target: self, action: #selector(FavoriteViewController.editButtonPressed))
            
            setBackgroundImage(show: false)
            return favorites.count
        } else {
            self.navigationItem.rightBarButtonItem = nil
            setBackgroundImage(show: true)
            return 0
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavoriteTableViewCell
        
        cell.foodLabel.text = self.favorites[indexPath.row]
        
        let description = safetyDescription[self.favorites[indexPath.row]]
        cell.safetyDescription.text = description
        
        cell.categoryIcon.image = getCategory(food: self.favorites[indexPath.row])
        
        let safetyResult = safety[self.favorites[indexPath.row]]
        
        if safetyResult == "safe" {
            cell.safetyIcon.image = UIImage(named: "smile.png")
        } else if safetyResult == "not safe" {
            cell.safetyIcon.image = UIImage(named: "frown.png")
        } else {
            cell.safetyIcon.image = UIImage(named: "question.png")
        }
        
        cell.safetyIcon.layer.zPosition = 1
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return (tabBarController?.tabBar.frame.height)!
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 5 , height: (tabBarController?.tabBar.frame.height)!))
        
        return footerView
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
