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
    var safety = [String: String]()
    var safetyDescription = [String: String]()

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var segmentedControl: UISegmentedControl!

    @IBAction func segmentedControlChange(_ sender: Any) {
        tableView.reloadData()
    }
    
    @IBAction func unwindToFoodCancel(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToFoodWithFilter(segue: UIStoryboardSegue) {
        segmentedControl.selectedSegmentIndex = 0 //default to All when coming from Category filter
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if category == "All" {
            navigationItem.title = "Food"
        } else {
            navigationItem.title = category
            loadFilteredList()
        }
        
        loadRecentList()

        tableView.reloadData()
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
/*
//Inserts bar button image
        let button = UIButton.init(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let filterButton = UIBarButtonItem(customView: button)
        
        button.setImage(UIImage(named: "filter.png"), for: UIControlState.normal)
        button.addTarget(self, action: #selector(categoryFilterButton), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = filterButton
*/
        loadFoodList()
        loadRecentList()
    
        tableView.reloadData()
        
    }
    
    func categoryFilterButton() {
        self.performSegue(withIdentifier: "goToCategoryFilter", sender: self)
    }
    
    func setClearButton(isRecent: Bool) {
        
        if isRecent {
        
            let button = UIButton.init(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30 )
            let clearButton = UIBarButtonItem(customView: button)
    
            button.setImage(UIImage(named: "delete.png"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(FoodViewController.deleteRecent), for: UIControlEvents.touchUpInside)
        
            self.navigationItem.rightBarButtonItem = clearButton
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    func loadFoodList() {
        
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        let foodSort = NSSortDescriptor(key: "foodName", ascending: true)
        fetchRequest.sortDescriptors = [foodSort]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                
                foodList.removeAll()
                safety.removeAll()
                safetyDescription.removeAll()
                
                for result in results as [Food] {
                    if let foodItem = result.foodName {
                        self.foodList.append(foodItem)
                        
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
                        
                    }  else {
                        print("Couldn't add foodItem \(String(describing: result.foodName))")
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
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
                        print("Couldn't add foodItem \(String(describing: result.foodName))")
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
        
        let alert = UIAlertController(title: "Clear Recent", message: "Are you sure you want to clear recent items?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (action: UIAlertAction!) in
            
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
            
            self.recentFoodList.removeAll()
            self.navigationItem.rightBarButtonItem = nil
            self.tableView.reloadData()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)

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
        case "Nutrients":
            categoryIcon = UIImage(named: "nutrients.png")!
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

                let description = safetyDescription[self.foodList[indexPath.row]]
                cell.safetyDescription.text = description
                
                cell.categoryIcon.image = getCategory(food: self.foodList[indexPath.row])
                
                let safetyResult = safety[self.foodList[indexPath.row]]

                if safetyResult == "safe" {
                    cell.safetyIcon.image = UIImage(named: "smile.png")
                } else if safetyResult == "not safe" {
                    cell.safetyIcon.image = UIImage(named: "frown.png")
                } else {
                    cell.safetyIcon.image = UIImage(named: "question.png")
                }
            } else {
                cell.foodLabel.text = self.foodListFiltered[indexPath.row]

                let description = safetyDescription[self.foodListFiltered[indexPath.row]]
                cell.safetyDescription.text = description
                
                cell.categoryIcon.image = getCategory(food: self.foodListFiltered[indexPath.row])
                
                let safetyResult = safety[self.foodListFiltered[indexPath.row]]
                
                if safetyResult == "safe" {
                    cell.safetyIcon.image = UIImage(named: "smile.png")
                } else if safetyResult == "not safe" {
                    cell.safetyIcon.image = UIImage(named: "frown.png")
                } else {
                    cell.safetyIcon.image = UIImage(named: "question.png")
                }
            }
            setClearButton(isRecent: false)
            break
        case 1:
            cell.foodLabel.text = self.recentFoodList[indexPath.row]

            let description = safetyDescription[self.recentFoodList[indexPath.row]]
            cell.safetyDescription.text = description

            cell.categoryIcon.image = getCategory(food: self.recentFoodList[indexPath.row])

            let safetyResult = safety[self.recentFoodList[indexPath.row]]
            
            if safetyResult == "safe" {
                cell.safetyIcon.image = UIImage(named: "smile.png")
            } else if safetyResult == "not safe" {
                cell.safetyIcon.image = UIImage(named: "frown.png")
            } else {
                cell.safetyIcon.image = UIImage(named: "question.png")
            }
            setClearButton(isRecent: true)
            break
        default:
            break
        }
        
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
