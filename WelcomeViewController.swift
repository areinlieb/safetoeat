//
//  WelcomeViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/24/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData
import Parse

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        //self.layer.backgroundColor = UIColor(red: 248/255, green: 191/255, blue: 222/255, alpha: 1).cgColor
        self.layer.masksToBounds = false
        //self.layer.shadowColor = UIColor.darkGray.cgColor
        //self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        //self.layer.shadowOpacity = 1.0
        //self.layer.shadowRadius = 0.0
    }
}

class WelcomeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var loginButton: UIButton!
    @IBOutlet var termsofServiceButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    let activityView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
         
        let queueLoadCategories = DispatchQueue(label: "loadCategoriesQueue")
        let queueRecipes = DispatchQueue(label: "recipesQueue", qos: DispatchQoS.default)
        let queueRecipeCategories = DispatchQueue(label: "recipeCategoryQueue", qos: DispatchQoS.default)

        queueLoadCategories.async {
            LoadData.loadCategories()
        }
        
        queueRecipes.async {
            LoadData.loadRecipes()
        }
        
        queueRecipeCategories.async {
            LoadData.loadRecipeCategories()
        }
        
        loginButton.setImage(UIImage(named: "go.png"), for: .normal)
        loginButton.setImage(UIImage(named: "go green.png"), for: .highlighted)

    }
    
    @IBAction func termsOfServiceAction(_ sender: Any) {
        
        DispatchQueue.main.async(execute: { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Legal Welcome")
            self.present(viewController, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        self.activityView.color = UIColor.black
        self.activityView.isHidden = false
        self.activityView.center = self.view.center
        self.activityView.startAnimating()
        self.view.addSubview(activityView)
        
        
        loginProcess()
    }
    
    func loginProcess() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateUpdated = dateFormatter.string(from: NSDate() as Date)
        
        defaults.set(dateUpdated + "@email.com", forKey: "email")
        
        if (PFUser.current() != nil) {
            
            let existingUser = PFUser.current()
            
            existingUser?.username = dateUpdated
            existingUser?.email = dateUpdated + "@email.com"
            existingUser?.password = "password"
            
            existingUser?.saveInBackground(block: { (success, error) in
                
                if success {
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                    })
                } else if error!.localizedDescription == "Account already exists for this username." {
                    
                    // Send a request to login
                    PFUser.logInWithUsername(inBackground: (existingUser?.username!)!, password: (existingUser?.password!)!, block: { (user, error) -> Void in
                        
                        if ((user) != nil) {
                            
                            DispatchQueue.main.async(execute: {
                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                                self.present(viewController, animated: true, completion: nil)
                                
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                            })
                            
                        } else {
                            
                            let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please make sure you're connected to a network and try again. This is only required the first time.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                            self.present(alert, animated: true){}
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            
                        }
                    })
                } else {
                    let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please make sure you're connected to a network and try again. This is only required the first time.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                    self.present(alert, animated: true){}
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                }
                
            })
        } else {
        
            let newUser = PFUser()

            newUser.username = dateUpdated
            newUser.email = dateUpdated + "@email.com"
            newUser.password = "password"
        
            // Sign up the user asynchronously
            newUser.signUpInBackground(block: { (success, error) -> Void in
                    
                if ((error) != nil) {
                
                    let alert = UIAlertController(title: "Ah, shitake mushrooms!", message: "Please make sure you're connected to a network and try again. This is only necessary the first time.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                    self.present(alert, animated: true){}
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                                    
                } else {
                
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                    })
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
