//
//  RecipePageViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 6/27/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class RecipePageViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    var selectedURL = String()
    
/*    func configureView() {
        // Update the user interface for the detail item.
        
        if let detail = self.detailItem {
            
            self.title = detail.value(forKey: "title") as! String
            
            if let recipeWebView = self.webView {
                
                recipeWebView.loadHTMLString(detail.value(forKey: "content") as! String, baseURL: "https://www.nutriliving.com/recipes/nuts-seeds-and-greens")
                
            }
            
        }
        
    }
     
     var detailItem: Event? {
     didSet {
     // Update the view.
     self.configureView()
     }
     }
*/
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("The URL is \(selectedURL)")

        let url = URL(string: selectedURL)
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
        
    }
    
/*    override func viewDidAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnSwipe = true;
    }
*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
