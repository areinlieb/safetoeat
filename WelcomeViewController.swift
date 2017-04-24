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

class WelcomeViewController: UIViewController {

    @IBOutlet var usernameField: UITextField!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var termsofServiceButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
       // usernameField.setBottomBorder()
        usernameField.becomeFirstResponder()
        
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
    
    func loginProcess() {
        
        if self.usernameField.text == "" {
            
            let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please enter a valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
            self.present(alert, animated: true){}
            
        } else {
            
            //add to Core data
            let newEmail = NSEntityDescription.insertNewObject(forEntityName: "User", into: DatabaseController.getContext()) as! User
            newEmail.email = self.usernameField.text
            DatabaseController.saveContext()
            
            //attempt to add to parse
            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            if (PFUser.current() != nil) {
                
                let existingUser = PFUser.current()
                
                existingUser?.username = newEmail.email
                existingUser?.email = newEmail.email
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
            
                newUser.username = newEmail.email
                newUser.email = newEmail.email
                newUser.password = "password"
            
                // Sign up the user asynchronously
                newUser.signUpInBackground(block: { (success, error) -> Void in
                    
                    if ((error) != nil) {
                    
                        if error!.localizedDescription == "Account already exists for this username." {
                            
                            // Send a request to login
                            PFUser.logInWithUsername(inBackground: newUser.email!, password: newUser.password!, block: { (user, error) -> Void in
                                
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
                            self.present(alert, animated: true)
                        }                    
                    } else {
                    
                        DispatchQueue.main.async(execute: { () -> Void in
                            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                            self.present(viewController, animated: true, completion: nil)
                        })
                    }
                })
                
                // Stop the spinner
                spinner.stopAnimating()
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
