//
//  SignUpViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/7/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

/*extension UITextField {
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
*/

extension UIViewController {
    func alertMessageOk(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

class SignUpViewController: UIViewController {
    

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usernameField.setBottomBorder()
        passwordField.setBottomBorder()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        let username = self.usernameField.text
        let password = self.passwordField.text
        
        if usernameField.text == "" || passwordField.text == "" {
            
            let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please enter a valid email and password", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
            self.present(alert, animated: true){}
            
        } else {

            let spinner: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 150, height: 150)) as UIActivityIndicatorView
            spinner.startAnimating()
            
            let newUser = PFUser()
            
            newUser.username = username
            newUser.email = username
            newUser.password = password
            
            // Sign up the user asynchronously
            newUser.signUpInBackground(block: { (succeed, error) -> Void in
                
                // Stop the spinner
                spinner.stopAnimating()
                if ((error) != nil) {

                    let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please enter a valid email and password", preferredStyle: .alert)
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

}
