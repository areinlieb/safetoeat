//
//  SearchViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var backgroundImage: UIView!
    
    var foodList = [String()]
    var foodListFiltered = [String]()
    var recentSearches = [String]()
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            let DestViewController : FoodDetailViewController = segue.destination as! FoodDetailViewController
            
            if searchController.isActive && searchController.searchBar.text != "" {
                DestViewController.food = foodListFiltered[(tableView.indexPathForSelectedRow?.row)!]
            } else {
                DestViewController.food = recentSearches[(tableView.indexPathForSelectedRow?.row)!]
            }

            navigationItem.title = "Food"
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationController?.isNavigationBarHidden = true

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //check to see if any data is in coredata, and if not, ask user to reload
        //reloadData()

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
        
        navigationController?.isNavigationBarHidden = true

        if recentSearches.count == 0 {
            backgroundImage.isHidden = false
            backgroundImage.layer.zPosition = 1
        } else {
            backgroundImage.isHidden = true
            backgroundImage.layer.zPosition = 0
        }
        
        self.resultsController.tableView.dataSource = self
        self.resultsController.tableView.delegate = self
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        
    }
    
    func reloadData() {
     
        let fetchRequest:NSFetchRequest<Food> = Food.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count == 0 {

                let alert = UIAlertController(title: "Internet connection required during first launch", message: "Please force quit this app, connect to the internet, and restart. An internet connection isn't required after the initial launch", preferredStyle: UIAlertControllerStyle.alert)
                
                present(alert, animated: true, completion: nil)

            }
        } catch {
            print("No internet connection on first launch")
        }
        
    
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.foodListFiltered = self.foodList.filter { (foodList: String) -> Bool in
            
            return foodList.lowercased().contains(self.searchController.searchBar.text!.lowercased())
            
        }
        
        self.tableView.reloadData()
        
    }
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        
        if recentSearches.count > 0 || (searchController.isActive && searchController.searchBar.text != "") {
            self.tableView.backgroundView = nil
            return 1
        } else {
             return 0
        }
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            backgroundImage.isHidden = true
            backgroundImage.layer.zPosition = 0
            return self.foodListFiltered.count
        } else if recentSearches.count > 0 {
            backgroundImage.isHidden = true
            backgroundImage.layer.zPosition = 0
            return self.recentSearches.count
        } else {
            backgroundImage.isHidden = false
            backgroundImage.layer.zPosition = 1
            return 0
        }
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            cell.textLabel?.text = self.foodListFiltered[indexPath.row]
        } else if recentSearches.count > 0 {
            cell.textLabel?.text = self.recentSearches[indexPath.row]
        }
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
        recentSearches.append(foodListFiltered[indexPath.row])
        
        
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

       /* if self.footerView != nil {
            return self.footerView!.bounds.height
        }
    
        return footerHeight*/
        
        return (50.0)
    }

    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 10, height: 30))
        
        button.setTitle("Clear recent searches", for: UIControlState.normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(deleteRecent), for: UIControlEvents.touchUpInside)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 5 , height: 50))
        footerView.addSubview(button)
        
        return footerView
        
    }
    
    func deleteRecent() {
    
        recentSearches.removeAll()
        tableView.reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
