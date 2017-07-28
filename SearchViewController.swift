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
import GoogleMobileAds
import Firebase

class SearchViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6303297723397278/4158106644"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var foodList = [String()]
    var foodListFiltered = [String]()
    var recentSearches = [String]()
    var safety = [String: String]()
    var safetyDescription = [String: String]()

    var searchController: UISearchController!
    var resultsController = UITableViewController()
    
    var backgroundView = UIImageView(image: UIImage(named: "search food icon.png"))
    var backgroundText = UILabel()
    
    let defaults = UserDefaults.standard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToFoodDetail" {
            
            let DestViewController : FoodDetailViewController = segue.destination as! FoodDetailViewController
            
            if searchController.isActive && searchController.searchBar.text != "" {
                DestViewController.food = foodListFiltered[(tableView.indexPathForSelectedRow?.row)!]
            } else {
                DestViewController.food = recentSearches[(tableView.indexPathForSelectedRow?.row)!]
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if !defaults.bool(forKey: "removeAds") {
            adBannerView.load(GADRequest())
        }
        
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
        self.searchController.searchBar.placeholder = "what food are you curious about?"
        definesPresentationContext = true
        
    }

    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        //print("Banner loaded successfully")
        
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        bannerView.frame = CGRect(x:0.0, y: screenHeight - bannerView.frame.size.height - (self.tabBarController?.tabBar.frame.height)!, width: bannerView.frame.size.width, height: bannerView.frame.size.height)
        
        if !defaults.bool(forKey: "removeAds") {
            view.superview?.addSubview(bannerView)
        }
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {

        //print("Fail to receive ads")
        //print(error)
    }
    
    func setClearButton(searchResults: Bool) {
        
        if searchResults {
                 
            let trashCan = UIBarButtonItem(image: UIImage(named: "trash can 25"), style: .done, target: self, action: #selector(SearchViewController.deleteSearches))
            self.navigationItem.rightBarButtonItem = trashCan
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
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
                            //print("Couldn't get safety result for foodItem \(String(describing: result.foodName))")
                        }

                        if let foodDescription = result.safetyDescription as? NSArray {
                            self.safetyDescription[foodItem] = foodDescription[0] as? String
                        } else {
                            //print("Couldn't get safety description for foodItem \(String(describing: result.foodName))")
                        }

                    }  else {
                        //print("Couldn't add foodItem \(String(describing: result.foodName))")
                    }
                }
            }
        } catch {
            //print("Error: \(error)")
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
            //print("Error: \(error)")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        self.foodListFiltered = self.foodList.filter { (foodList: String) -> Bool in
   
            return foodList.lowercased().contains(self.searchController.searchBar.text!.lowercased())
    
        }

        self.tableView.reloadData()

    }
    
    func deleteSearches() {
        
        let alert = UIAlertController(title: "Clear Searches", message: "Are you sure you want to clear recent searches?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (action: UIAlertAction!) in
            
            self.setBackgroundImage(show: true)
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
            
            self.recentSearches.removeAll()
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
            //print("Error: \(error)")
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
            setClearButton(searchResults: false)
            setBackgroundImage(show: false)
            
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

        } else if recentSearches.count > 0 {
            setClearButton(searchResults: true)
            setBackgroundImage(show: false)
            
            cell.foodLabel.text = self.recentSearches[indexPath.row]

            let description = safetyDescription[self.recentSearches[indexPath.row]]
            cell.safetyDescription.text = description
            
            cell.categoryIcon.image = getCategory(food: self.recentSearches[indexPath.row])

            let safetyResult = safety[self.recentSearches[indexPath.row]]
            
            if safetyResult == "safe" {
                cell.safetyIcon.image = UIImage(named: "smile.png")
            } else if safetyResult == "not safe" {
                cell.safetyIcon.image = UIImage(named: "frown.png")
            } else {
                cell.safetyIcon.image = UIImage(named: "question.png")
            }
            
        } else if recentSearches.count == 0 {
            setClearButton(searchResults: false)
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
            //print("Couldn't fetch results")
        }
        
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
