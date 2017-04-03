//
//  SearchViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData
import Parse

class SearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var foodList = [String()]
    var foodListFiltered = [String]()
    var recentSearches = [String]()
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    
    var backgroundView = UIImageView(image: UIImage(named: "search food icon.png"))
    var backgroundText = UILabel()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            print("in prepare")
            
            let DestViewController : FoodDetailViewController = segue.destination as! FoodDetailViewController
            
            if searchController.isActive && searchController.searchBar.text != "" {
                DestViewController.food = foodListFiltered[(tableView.indexPathForSelectedRow?.row)!]
                print ("food list filtered segue")
                
            } else {
                DestViewController.food = recentSearches[(tableView.indexPathForSelectedRow?.row)!]
                print ("recent searches segue")
            }

            //self.navigationItem.title = "Food"
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationItem.title = "Search"
        
        loadSearches()
        
        if recentSearches.count == 0 {
            setBackgroundImage(show: true)
        } else {
            setBackgroundImage(show: false)
        }
        
        self.tableView.reloadData()
        self.tableView.sendSubview(toBack: backgroundView)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadFoodList()
        loadSearches()
        
        navigationItem.title = "Search"
        
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.frame.size.width = 100
        backgroundView.frame.size.height = 100
        backgroundView.center = self.view.center
        backgroundView.frame.origin.y = self.view.center.y * 0.5
        
        self.tableView.sendSubview(toBack: backgroundView)

        backgroundText.text = "Search SafeToEat by food"
        backgroundText.textColor = UIColor(red: 66.0/255.0, green: 68.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        backgroundText.contentMode = .scaleAspectFit
        
        //SIZE OF IMAGE AND TEXT SHOULD SCALE BASED ON SCREEN SIZE
        backgroundText.frame.size.width = 200
        backgroundText.frame.size.height = 20
        
        backgroundText.center = self.view.center
        backgroundText.frame.origin.y = self.view.center.y * 0.90
        
        self.tableView.sendSubview(toBack: backgroundText)

        self.resultsController.tableView.dataSource = self
        self.resultsController.tableView.delegate = self
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.tableView.tableHeaderView = self.searchController.searchBar
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "enter food here"
        definesPresentationContext = true
        
    }
    
    
    func saveEmailtoParse() {
        
        var savedEmail = ""
        let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [User] {
                    savedEmail = result.email!
                }
            }
        } catch {
            print("Couldn't fetch results")
        }
        
        let user = PFUser.current()
        user?.username = savedEmail
        user?.email = savedEmail
        user?.saveEventually()
        print(savedEmail)
        
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
    
    func loadFoodList() {

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
        
    }
    
    func loadSearches() {
        
        recentSearches.removeAll()
        let fetchRequest:NSFetchRequest<Searches> = Searches.fetchRequest()
        let foodSortRecent = NSSortDescriptor(key: "timeAdded", ascending: false)
        
        fetchRequest.sortDescriptors = [foodSortRecent]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [Searches] {
                    if let foodItem = result.foodName {
                        self.recentSearches.append(foodItem)
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
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
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if searchController.isActive && searchController.searchBar.text != "" {
            setBackgroundImage(show: false)
            return self.foodListFiltered.count
        } else if recentSearches.count > 0 {
            setBackgroundImage(show: false)
            return self.recentSearches.count
        } else {
            setBackgroundImage(show: true)
            return 0
        }

    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            setBackgroundImage(show: false)
            cell.textLabel?.text = self.foodListFiltered[indexPath.row]
        } else if recentSearches.count > 0 {
            setBackgroundImage(show: false)
            cell.textLabel?.text = self.recentSearches[indexPath.row]
        } else if recentSearches.count == 0 {
            setBackgroundImage(show: true)
        }
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        var selectedFood = ""
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedFood = foodListFiltered[indexPath.row]
        } else if recentSearches.count > 0 {
            selectedFood = recentSearches[indexPath.row]
        }
        
        //add to core data
        let requestFood: NSFetchRequest<Searches> = Searches.fetchRequest()
        requestFood.returnsObjectsAsFaults = false
        
        do {
            
            let foodResults = try DatabaseController.getContext().fetch(requestFood)
            
            if foodResults.count > 0 {
                
                for result in foodResults as [Searches] {
                    
                    if let foodType = result.value(forKey: "foodName") as? String {
                        
                        if foodType == selectedFood {
                            DatabaseController.getContext().delete(result)
                        }
                    }
                }
            }
            
            let newFood = NSEntityDescription.insertNewObject(forEntityName: "Searches", into: DatabaseController.getContext()) as! Searches
            
            newFood.foodName = selectedFood
            newFood.timeAdded = NSDate()
            
            DatabaseController.saveContext()
            
        } catch {
            print("Couldn't fetch results")
        }
        
        
        
    }
    
    internal func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        if recentSearches.count > 0 && foodListFiltered.count == 0 {
            return (50.0)
        } else {
            return (0.0)
        }
        
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {

        let button = UIButton(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 10, height: 30))
        
        button.setTitle("clear recent searches", for: UIControlState.normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(deleteSearches), for: UIControlEvents.touchUpInside)
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width - 5 , height: 50))
        footerView.addSubview(button)
        
        return footerView
        
    }
    
    func deleteSearches() {
    
        recentSearches.removeAll()
        
        setBackgroundImage(show: true)
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
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
