//
//  CategoryFilterViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/8/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData

class CategoryFilterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    
    var allFoodTypes = [String()]

    var foodCategoryTypes = [String]()
    var foodCategoryImages = [UIImage]()

    var selectedCategory = ""
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
        if let DestViewController = segue.destination as? FoodViewController {
            if let row = tableView.indexPathForSelectedRow?.row {
                DestViewController.category = foodCategoryTypes[row]
             }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {

        //load category list
        loadCategories()
        
        tableView.reloadData()
        
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()

        //load category list
        loadCategories()
        
        tableView.reloadData()
        
    }

    func loadCategories() {
        
        let fetchRequest:NSFetchRequest<Category> = Category.fetchRequest()
        let categorySort = NSSortDescriptor(key: "categoryName", ascending: true)
        fetchRequest.sortDescriptors = [categorySort]
        
        if foodCategoryTypes.count == 0 && foodCategoryImages.count == 0 {
            
            do {
                
                let results = try DatabaseController.getContext().fetch(fetchRequest)
                
                if results.count > 0 {
                    
                    for result in results as [Category] {
                        
                        if let foodCategory = result.categoryName {
                            foodCategoryTypes.append(foodCategory)
                        }
                        
                        if let categoryIcon = result.categoryIcon {
                            foodCategoryImages.append(UIImage(data: categoryIcon as Data)!)
                        }
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodCategoryTypes.count
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryFilterTableViewCell
        
        cell.categoryIcon.image = foodCategoryImages[indexPath.row]
        cell.categoryLabel.text = foodCategoryTypes[indexPath.row]
        
        if foodCategoryTypes[indexPath.row] == selectedCategory {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
        }
        
        return cell
        
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        selectedCategory = foodCategoryTypes[indexPath.row]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
