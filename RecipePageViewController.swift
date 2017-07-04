//
//  RecipePageViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 6/27/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class RecipePageViewController: UIViewController, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    
    var selectedURL = String()
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let url = URL(string: selectedURL)
        let request = URLRequest(url: url!)
        
        webView.delegate = self
        webView.loadRequest(request)
        
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        self.activityView.color = UIColor.black
        self.activityView.isHidden = false
        self.activityView.center = self.view.center
        self.activityView.startAnimating()
        self.view.addSubview(activityView)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        self.activityView.isHidden = true
        self.activityView.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {

        if error._code != NSURLErrorCancelled {
            
            let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"An internet connection is required to access Recipes. Please make sure you're connected to a network and then hit the Refresh button.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Refresh", style: .default, handler: { action in
                webView.reload()
            }))
            
            self.present(alert, animated: true){}
        }
 
    }
 
    @IBAction func refreshButton(_ sender: Any) {
        webView.reload()
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
