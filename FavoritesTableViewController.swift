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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            let DestViewController : FoodDetailViewController = segue.destination as! FoodDetailViewController
            
            DestViewController.food = favorites[(tableView.indexPathForSelectedRow?.row)!]
            navigationItem.title = "Food"
            
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        
        //retrieve favorites list
        loadFavoriteList()
        
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        self.navigationItem.rightBarButtonItem = self.editButtonItem

        //retrieve favorites list
        loadFavoriteList()
        
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

    func confirmDelete(_ food: String) {
        
        selectedFavorite = food
        
        let alert = UIAlertController(title: "Delete Favorite", message: "Are you sure you want to delete \(food)?", preferredStyle: .actionSheet)
        
        let DeleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: handleDeleteFavorite)
        let CancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: cancelDeleteFavorite)
        
        alert.addAction(DeleteAction)
        alert.addAction(CancelAction)
        
        // Support presentation in iPad
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width / 2.0, y: self.view.bounds.size.height / 2.0, width: 1.0, height: 1.0)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleDeleteFavorite(_ alertAction: UIAlertAction!) -> Void {
        
        if let indexPath = deleteFavoritesIndexPath {
            
            tableView.beginUpdates()
            
            favorites.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic) // Note that indexPath is wrapped in an array:  [indexPath]
            deleteFavoritesIndexPath = nil
            
            //print("Index Path = \(indexPath) , Table View IP = \(tableView.cellForRow(at: indexPath)?.textLabel)")
            
            print("Food = \(selectedFavorite)")
            
            tableView.endUpdates()
            
            //delete from core data

            let requestFood: NSFetchRequest<Favorites> = Favorites.fetchRequest()
            requestFood.returnsObjectsAsFaults = false
            
            do {
                
                let foodResults = try DatabaseController.getContext().fetch(requestFood)
                
                if foodResults.count > 0 {
                    
                    for result in foodResults as [Favorites] {
                        
                        if let foodType = result.value(forKey: "foodName") as? String {
                            
                            if foodType == selectedFavorite {
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
    
    func cancelDeleteFavorite(_ alertAction: UIAlertAction!) {
        deleteFavoritesIndexPath = nil
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            deleteFavoritesIndexPath = indexPath
            let favoriteToDelete = favorites[indexPath.row]
            confirmDelete(favoriteToDelete)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favorites.count
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
