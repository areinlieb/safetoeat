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
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //usernameField.setBottomBorder()
        //usernameField.becomeFirstResponder()
        //self.usernameField.delegate = self
        
        loginButton.setImage(UIImage(named: "go blank.png"), for: .normal)
        
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
        loginButton.setImage(UIImage(named: "go filled.png"), for: .normal)
    }
    
    func loginProcess() {
        
        let newUser = PFUser()
        newUser.username = "username"
        newUser.email = "username@email.com"
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
