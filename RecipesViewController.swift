//
//  RecipesViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 6/27/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData
import Parse

class RecipesViewController: UIViewController, UISearchResultsUpdating, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var indexPaths = [NSIndexPath]()
    var recipeList = [String()]
    var recipeListFiltered = [String]()
    var recentSearches = [String]()
    var recipeURL = [String: String]()
    var recipeIngredients = [String: String]()
    var recipeImageURL = [String: String]()
    
    var searchController: UISearchController!
    var resultsController = UITableViewController()
    
    var backgroundView = UIImageView(image: UIImage(named: "search food icon.png"))
    var backgroundText = UILabel()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showRecipePage" {
            
            //let nav = segue.destination as! UINavigationController
            //let DestViewController = nav.topViewController as! RecipePageViewController
            let DestViewController : RecipePageViewController = segue.destination as! RecipePageViewController
        
            if searchController.isActive && searchController.searchBar.text != "" {
                DestViewController.selectedURL = recipeURL[recipeListFiltered[(tableView.indexPathForSelectedRow?.row)!]]!
            } else {
                DestViewController.selectedURL = recipeURL[recipeList[(tableView.indexPathForSelectedRow?.row)!]]!
            }
        }

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        navigationItem.title = "Recipes"
        
        loadRecipes()
        
        self.tableView.reloadData()
        self.tableView.sendSubview(toBack: backgroundView)
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        loadRecipes()
        loadSearches()
        
        navigationItem.title = "Recipes"
        
        backgroundView.contentMode = .scaleAspectFit
        backgroundView.frame.size.width = 100
        backgroundView.frame.size.height = 100
        backgroundView.center = self.view.center
        backgroundView.frame.origin.y = self.view.center.y * 0.5
        
        self.tableView.sendSubview(toBack: backgroundView)
        
        backgroundText.text = "Search Recipes by food"
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
        self.searchController.searchBar.placeholder = "what are you craving?"
        definesPresentationContext = true
        
    }
    
    func setClearButton(searchResults: Bool) {
        
        if searchResults {
            
            let button = UIButton.init(type: .custom)
            button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            let clearButton = UIBarButtonItem(customView: button)
            
            button.setImage(UIImage(named: "delete white.png"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(SearchViewController.deleteSearches), for: UIControlEvents.touchUpInside)
            
            self.navigationItem.rightBarButtonItem = clearButton
            
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
    }
    
    func loadRecipes() {
        
        let fetchRequest:NSFetchRequest<Recipes> = Recipes.fetchRequest()
        
        let recipeSort = NSSortDescriptor(key: "recipeTitle", ascending: true)
        fetchRequest.sortDescriptors = [recipeSort]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                
                recipeList.removeAll()
                recipeURL.removeAll()
                recipeIngredients.removeAll()
                recipeImageURL.removeAll()
                
                for result in results as [Recipes] {
                    if let recipeItem = result.recipeTitle {
                        self.recipeList.append(recipeItem)
                        
                        if let url = result.recipeURL {
                            self.recipeURL[recipeItem] = url
                        } else {
                            print("Couldn't get recipe URL for recipe \(String(describing: result.recipeTitle))")
                        }
                        
                        if let imageURL = result.recipeImageURL {
                            self.recipeImageURL[recipeItem] = imageURL
                        } else {
                            print("Couldn't get recipe Image URL for recipe \(String(describing: result.recipeTitle))")
                        }
                        
                        if let ingredientList = result.ingredients as? NSArray {
                            self.recipeIngredients[recipeItem] = ingredientList.componentsJoined(by: ", ")
                        } else {
                            print("Couldn't get ingredients for recipe \(String(describing: result.recipeTitle))")
                        }
                        
                    }  else {
                        print("Couldn't add recipe \(String(describing: result.recipeTitle))")
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func loadSearches() {
        
        recentSearches.removeAll()
        let fetchRequest:NSFetchRequest<SearchesRecipes> = SearchesRecipes.fetchRequest()
        let recipeSortRecent = NSSortDescriptor(key: "timeAdded", ascending: false)
        
        fetchRequest.sortDescriptors = [recipeSortRecent]
        
        do {
            
            let results = try DatabaseController.getContext().fetch(fetchRequest)
            
            if results.count > 0 {
                for result in results as [SearchesRecipes] {
                    if let recipeItem = result.recipeTitle {
                        self.recentSearches.append(recipeItem)
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    func reloadData() {
        
        let fetchRequest:NSFetchRequest<Recipes> = Recipes.fetchRequest()
        
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
 
        recipeListFiltered.removeAll()
        
        for (key, value) in recipeIngredients {
            if key.lowercased().contains(self.searchController.searchBar.text!.lowercased()) || value.contains(self.searchController.searchBar.text!.lowercased()) {
                recipeListFiltered.append(key)
            }
        }

        self.tableView.reloadData()
 
    }
    
    func deleteSearches() {
 
        let alert = UIAlertController(title: "Clear Searches", message: "Are you sure you want to clear recent searches?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Clear", style: .default, handler: { (action: UIAlertAction!) in
            
            let fetchRequest:NSFetchRequest<SearchesRecipes> = SearchesRecipes.fetchRequest()
            
            do {
                
                let results = try DatabaseController.getContext().fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as [SearchesRecipes] {
                        DatabaseController.getContext().delete(result)
                    }
                }
            } catch {
                print("Couldn't fetch results")
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
    
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return self.recipeListFiltered.count
        } else {
            return self.recipeList.count
        }
        
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! RecipesTableViewCell
        
        if searchController.isActive && searchController.searchBar.text != "" {
            setClearButton(searchResults: false)
            
            cell.recipeTitle.text = self.recipeListFiltered[indexPath.row]
            
            let foodIngredients = recipeIngredients[self.recipeListFiltered[indexPath.row]]
            cell.ingredients.text = foodIngredients
            
            let url = URL(string: recipeImageURL[recipeListFiltered[indexPath.row]]!)
            if url != nil {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        if data != nil {
                            cell.backgroundView = UIImageView(image: UIImage(data:data!))
                            cell.backgroundView?.contentMode = UIViewContentMode.scaleAspectFill
                       } else{
                            cell.backgroundView = UIImageView(image: UIImage(named: "default recipe.jpg"))
                            cell.backgroundView?.contentMode = UIViewContentMode.scaleAspectFill
                            //cell.backgroundView?.alpha = 0.7
                        }
                    }
                }
            }
            
        } else {

            cell.recipeTitle.text = self.recipeList[indexPath.row]
            
            let foodIngredients = recipeIngredients[self.recipeList[indexPath.row]]
            cell.ingredients.text = foodIngredients
            
            let url = URL(string: recipeImageURL[recipeList[indexPath.row]]!)
            if url != nil {
                DispatchQueue.global().async {
                    let data = try? Data(contentsOf: url!)
                    DispatchQueue.main.async {
                        if data != nil {
                            cell.backgroundView = UIImageView(image: UIImage(data:data!))
                            cell.backgroundView?.contentMode = UIViewContentMode.scaleAspectFill
                           
                        } else{
                            cell.backgroundView = UIImageView(image: UIImage(named: "default recipe.jpg"))
                            cell.backgroundView?.contentMode = UIViewContentMode.scaleAspectFill
                        }
                    }
                }
            }
        }
        
        let view = UIView()
        view.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = view
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var selectedRecipe = ""
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedRecipe = recipeListFiltered[indexPath.row]
        } else {
            selectedRecipe = recipeList[indexPath.row]
        }
        
        //add to core data
        let requestRecipe: NSFetchRequest<SearchesRecipes> = SearchesRecipes.fetchRequest()
        requestRecipe.returnsObjectsAsFaults = false
        
        do {
            
            let recipeResults = try DatabaseController.getContext().fetch(requestRecipe)
            
            if recipeResults.count > 0 {
                
                for result in recipeResults as [SearchesRecipes] {
                    
                    if let recipeType = result.value(forKey: "recipeTitle") as? String {
                        
                        if recipeType == selectedRecipe {
                            DatabaseController.getContext().delete(result)
                        }
                    }
                }
            }
            
            let newRecipe = NSEntityDescription.insertNewObject(forEntityName: "SearchesRecipes", into: DatabaseController.getContext()) as! SearchesRecipes
            
            newRecipe.recipeTitle = selectedRecipe
            newRecipe.timeAdded = NSDate()
            
            DatabaseController.saveContext()
            
        } catch {
            print("Couldn't fetch results")
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if (!indexPaths.contains(indexPath as NSIndexPath)) {
            
            indexPaths.append(indexPath as NSIndexPath)

            cell.alpha = 0
            let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 20, 0)
            cell.layer.transform = transform
            
            UIView.animate(withDuration: 0.7) {
                cell.alpha = 1.0
                cell.layer.transform = CATransform3DIdentity
            }

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
