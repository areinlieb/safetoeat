//
//  ResetPasswordViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/7/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func passwordReset(_ sender: Any) {
        
        if emailField.text == "" {
            
            let alert = UIAlertController(title: "Ah, shitake mushrooms!", message:"Please enter a valid email", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default) { _ in })
            self.present(alert, animated: true){}
            
        } else {
            
            let email = self.emailField.text

            // Send a request to reset a password
       //     PFUser.requestPasswordResetForEmail(inBackground: email!)
            
            PFUser.requestPasswordResetForEmail(inBackground: email!, block: { (success, error) in
                
                if error != nil {
                    
                    let alert = UIAlertController (title: "Uh oh", message: "We were unable to reset your email. Please try again", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    
                    let alert = UIAlertController (title: "Password Reset", message: "An email containing information on how to reset your password has been sent to " + email! + ".", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                
            })
            
            
        }

    }
    
}
