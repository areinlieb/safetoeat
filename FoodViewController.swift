//
//  FoodViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/8/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData

class FoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var category = "All"
    var foodList = [String()]
    var foodListFiltered = [String()]
    var recentFoodList = [String()]

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControlChange(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func unwindToFoodCancel(segue: UIStoryboardSegue) {
        print("Category on Cancel is \(category)")
    }
    
    @IBAction func unwindToFoodWithFilter(segue: UIStoryboardSegue) {
        print("Category on Filter is \(category)")
        segmentedControl.selectedSegmentIndex = 0 //default to All when coming from Category filter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if category == "All" {
            navigationItem.title = "Food"
        } else {
            navigationItem.title = category
            loadFilteredList()
        }
        
        //retrieve Recent list
        loadRecentList()

        tableView.reloadData()

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()

        let foodSort = NSSortDescriptor(key: "foodName", ascending: true)
        fetchRequest.sortDescriptors = [foodSort]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
        
                foodList.removeAll()
                
                for result in results as [Food] {
                    if let foodItem = result.foodName {
                        self.foodList.append(foodItem)
                    }  else {
                        print("Couldn't add foodItem \(result.foodName)")
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
        //retrieve Recent list
        loadRecentList()
        
        tableView.reloadData()
        
    }
    
    func loadFilteredList() {
        
        self.foodListFiltered.removeAll()
        
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "foodCategory == %@", category)
        
        let foodSort = NSSortDescriptor(key: "foodName", ascending: true)
        fetchRequest.sortDescriptors = [foodSort]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Food] {
                    if let foodItem = result.foodName {
                        self.foodListFiltered.append(foodItem)
                    }  else {
                        print("Couldn't add foodItem \(result.foodName)")
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func loadRecentList() {
        
        recentFoodList.removeAll()
        let fetchRequest:NSFetchRequest<Recent> = Recent.fetchRequest()
        let foodSortRecent = NSSortDescriptor(key: "timeAdded", ascending: false)
        
        fetchRequest.sortDescriptors = [foodSortRecent]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Recent] {
                    if let foodItem = result.foodName {
                        self.recentFoodList.append(foodItem)
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func deleteRecent() {
                
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
        
        recentFoodList.removeAll()
        
        self.tableView.reloadData()

    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToCategoryFilter" {
            
            let DestViewController : CategoryFilterViewController = segue.destination as! CategoryFilterViewController
            
            DestViewController.selectedCategory = category
            
        }
        
        if segue.identifier == "goToFoodDetail" {
            
            let DestViewController : FoodDetailViewController = segue.destination as! FoodDetailViewController
            
            switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                if category == "All" {
                    DestViewController.food = foodList[(tableView.indexPathForSelectedRow?.row)!]
                    navigationItem.title = "Food"
                } else {
                    DestViewController.food = foodListFiltered[(tableView.indexPathForSelectedRow?.row)!]
                    navigationItem.title = category
                }
                break
            case 1:
                DestViewController.food = recentFoodList[(tableView.indexPathForSelectedRow?.row)!]
                navigationItem.title = "Food"
                break
            default:
                break
            }
        }
        
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var rows = 0
        
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            navigationItem.title = category
            if category == "All" {
                rows = self.foodList.count
            } else {
                rows = self.foodListFiltered.count
            }
            break
        case 1:
            navigationItem.title = "Food"
            rows = self.recentFoodList.count
            break
        default:
            break
        }
    
        return rows
    
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FoodTableViewCell
        
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            if category == "All" {
                cell.foodLabel.text = self.foodList[indexPath.row]
            } else {
                cell.foodLabel.text = self.foodListFiltered[indexPath.row]
            }
            break
        case 1:
            cell.foodLabel.text = self.recentFoodList[indexPath.row]
            break
        default:
            break
        }
        
        return cell
        
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        /* if self.footerView != nil {
         return self.footerView!.bounds.height
         }
         
         return footerHeight*/
        
        return (50.0)
    }
 
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 5 , height: 50))

        switch (segmentedControl.selectedSegmentIndex) {
            case 0:
                break
            case 1:
                
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 10, height: 30))
        
                button.setTitleColor(UIColor.gray, for: .normal)

                if recentFoodList.count > 0 {
             
                    button.setTitle("Clear recent", for: UIControlState.normal)
                    button.addTarget(self, action: #selector(deleteRecent), for: UIControlEvents.touchUpInside)
    
                } else {
            
                    button.setTitle("No recent items", for: UIControlState.normal)
                    button.isEnabled = false
            
                }

                footerView.addSubview(button)
                break
            
            default:
                break
        }
        
        return footerView
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
