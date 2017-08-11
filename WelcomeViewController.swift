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

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var termsofServiceButton: UIButton!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let queueFruit = DispatchQueue(label: "fruitQueue", qos: DispatchQoS.default)
        let queueGrains = DispatchQueue(label: "grainsQueue", qos: DispatchQoS.default)
        let queueMeat = DispatchQueue(label: "meatQueue", qos: DispatchQoS.default)
        let queueNutrients = DispatchQueue(label: "nutrientsQueue", qos: DispatchQoS.default)
        let queueNuts = DispatchQueue(label: "nutsQueue", qos: DispatchQoS.default)
        let queueSeafood = DispatchQueue(label: "seafoodQueue", qos: DispatchQoS.default)
        
        let queueRecipes = DispatchQueue(label: "recipesQueue", qos: DispatchQoS.default)
        let queueRecipeCategories = DispatchQueue(label: "recipeCategoryQueue", qos: DispatchQoS.default)
        
        queueFruit.async {
            LoadData.loadFood(category: "Fruit")
        }
        
        queueGrains.async {
            LoadData.loadFood(category: "Grains")
        }
        
        queueMeat.async {
            LoadData.loadFood(category: "Meat")
        }
        
        queueNutrients.async {
            LoadData.loadFood(category: "Nutrients")
        }
        
        queueNuts.async {
            LoadData.loadFood(category: "Nuts, Seeds, & Legumes")
        }
        
        queueSeafood.async {
            LoadData.loadFood(category: "Seafood")
        }
        
        queueRecipes.async {
            LoadData.loadRecipes()
        }
        
        queueRecipeCategories.async {
            LoadData.loadRecipeCategories()
        }
        
        loginButton.setImage(UIImage(named: "go.png"), for: .normal)
        
    }
    
    @IBAction func termsOfServiceAction(_ sender: Any) {
        
        DispatchQueue.main.async(execute: { () -> Void in
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Legal Welcome")
            self.present(viewController, animated: true, completion: nil)
        })
        
    }
    
    @IBAction func loginAction(_ sender: Any) {
        loginProcess()
    }
    
    @IBAction func usernameFieldPrimaryActionTriggered(_ sender: Any) {        
        loginProcess()
    }
    
    @IBAction func usernameFieldEditingChanged(_ sender: Any) {
        loginButton.setImage(UIImage(named: "go green.png"), for: .normal)
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
                    })
                } else if error!.localizedDescription == "Account already exists for this username." {
                    
                    // Send a request to login
                    PFUser.logInWithUsername(inBackground: (existingUser?.username!)!, password: (existingUser?.password!)!, block: { (user, error) -> Void in
                        
                        if ((user) != nil) {
                            
                            DispatchQueue.main.async(execute: {
                                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                                self.present(viewController, animated: true, completion: nil)
                            })
                            
                        } else {
                            
                            let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please make sure you're connected to a network and try again. This is only required the first time.", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                            self.present(alert, animated: true){}
                            
                        }
                    })
                } else {
                    let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please make sure you're connected to a network and try again. This is only required the first time.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                    self.present(alert, animated: true){}
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
                                    
                } else {
                
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                        self.present(viewController, animated: true, completion: nil)
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
