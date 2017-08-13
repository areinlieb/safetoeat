//
//  FoodViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/8/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData
import GoogleMobileAds
import Firebase

class FoodViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate  {

    var category = "All"
    var foodList = [String()]
    var foodListFiltered = [String()]
    var recentFoodList = [String()]
    var favorites = [String()]
    var safety = [String: String]()
    var safetyDescription = [String: String]()
    
    var backgroundView = UIImageView(image: UIImage(named: "star background.png"))
    var backgroundText = UILabel()
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6303297723397278/4158106644"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    let defaults = UserDefaults.standard

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
        
        if !defaults.bool(forKey: "removeAds") {
            adBannerView.load(GADRequest())
        }
        
        if category == "All" {
            navigationItem.title = "Food"
        } else {
            navigationItem.title = category
            loadFilteredList()
        }
        
        loadRecentList()
        loadFavoriteList()

        tableView.reloadData()
        
        self.tableView.sendSubview(toBack: backgroundView)
        self.tableView.sendSubview(toBack: backgroundText)

    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width

        backgroundView.contentMode = .scaleAspectFit
        backgroundView.frame.size.width = screenWidth / 3
        backgroundView.frame.size.height = screenWidth / 3
        backgroundView.center = self.view.center
        backgroundView.frame.origin.y = (self.view.center.y * 0.80) - backgroundView.frame.size.height
        
        self.tableView.sendSubview(toBack: backgroundView)
        
        backgroundText.text = "No favorite items"
        backgroundText.textColor = UIColor(red: 66.0/255.0, green: 68.0/255.0, blue: 73.0/255.0, alpha: 1.0)
        backgroundText.contentMode = .scaleAspectFit
        backgroundText.textAlignment = .center
        backgroundText.frame.size.width = screenWidth / 2
        backgroundText.frame.size.height = screenWidth / 10
        
        backgroundText.center = self.view.center
        backgroundText.frame.origin.y = self.view.center.y * 0.80
        
        self.tableView.sendSubview(toBack: backgroundText)

        loadFoodList()
        loadRecentList()
        loadFavoriteList()
    
        tableView.reloadData()
        
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
    
    func categoryFilterButton() {
        self.performSegue(withIdentifier: "goToCategoryFilter", sender: self)
    }
    
    func setNavButton(segmentedTab: String) {
        
        if segmentedTab == "Recent" {
        
            let trashCan = UIBarButtonItem(image: UIImage(named: "trash can 25"), style: .done, target: self, action: #selector(FoodViewController.deleteRecent))
            self.navigationItem.rightBarButtonItem = trashCan
            setBackgroundImage(show: false)

            
        } else if segmentedTab == "Favorites" {
            
            self.navigationItem.rightBarButtonItem = nil
            if favorites.count > 0 {
                
                //self.navigationItem.rightBarButtonItem = self.editButtonItem
                setBackgroundImage(show: false)
                
            } else {
                
                //self.navigationItem.rightBarButtonItem = nil
                setBackgroundImage(show: true)
            }
            
        } else if segmentedTab == "All" {
            
            self.navigationItem.rightBarButtonItem = nil
            setBackgroundImage(show: false)

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
                        //print("Couldn't add foodItem \(String(describing: result.foodName))")
                    }
                }
            }
        } catch {
            //print("Error: \(error)")
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
            //print("Error: \(error)")
        }
        
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
            //print("Error: \(error)")
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
                //print("Couldn't fetch results")
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
            case 2:
                DestViewController.food = favorites[(tableView.indexPathForSelectedRow?.row)!]
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
            setNavButton(segmentedTab: "All")
            break
        case 1:
            navigationItem.title = "Food"
            rows = self.recentFoodList.count
            setNavButton(segmentedTab: "Recent")
            break
        case 2:
            navigationItem.title = "Food"
            rows = self.favorites.count
            setNavButton(segmentedTab: "Favorites")
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
            break
        case 2:
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
            break
        default:
            break
        }
        
        return cell
        
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
                //print("Couldn't fetch results")
            }
        }
    }
    
    internal func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            return false
        case 1:
            return false
        case 2:
            return true
        default:
            return false
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
