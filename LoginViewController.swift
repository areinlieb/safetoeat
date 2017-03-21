//
//  LoginViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/7/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor(red: 248/255, green: 191/255, blue: 222/255, alpha: 1).cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if PFUser.current() != nil {
            
            DispatchQueue.main.async(execute: { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                self.present(viewController, animated: true, completion: nil)
            })
            
        }
        
        usernameField.setBottomBorder()
        passwordField.setBottomBorder()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func loginAction(_ sender: Any) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
        spinner.startAnimating()
        
        // Send a request to login
        PFUser.logInWithUsername(inBackground: username!, password: password!, block: { (user, error) -> Void in
            
            // Stop the spinner
            spinner.stopAnimating()
            
            if ((user) != nil) {
                
                DispatchQueue.main.async(execute: {
                    let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                    self.present(viewController, animated: true, completion: nil)
                })
                
            } else {

                let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Incorrect login or password. If you don't have an account, please Sign Up", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
                self.present(alert, animated: true){}
                
            }
        })
        
    }    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
    }

}

