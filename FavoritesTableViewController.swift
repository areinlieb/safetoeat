//
//  FavoritesTableViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/12/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData

class FavoritesTableViewController: UITableViewController {

    var favorites = [String()]
    var selectedFavorite = ""
    var deleteFavoritesIndexPath: IndexPath? = nil
    
    var backgroundView = UIImageView(image: UIImage(named: "star background gray.png"))
    var backgroundText = UILabel()
    
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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.navigationItem.rightBarButtonItem = self.editButtonItem

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
        
        tableView.tableFooterView = UIView()

        tableView.reloadData()
        
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

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     
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

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if favorites.count > 0 {
            setBackgroundImage(show: false)
            return favorites.count
        } else {
            setBackgroundImage(show: true)
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavoritesTableViewCell
     
        cell.foodLabel.text = self.favorites[indexPath.row]
     
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
