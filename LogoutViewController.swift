//
//  LogoutViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/9/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class LogoutViewController: UIViewController {

    override func viewDidLoad() {
      
        super.viewDidLoad()
        
        let alert = UIAlertController(title: "Change email", message: "Are you sure you want to change your email?", preferredStyle: UIAlertControllerStyle.alert)
            
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action: UIAlertAction!) in
            
            PFUser.logOut()
          
            DispatchQueue.main.async(execute: { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Welcome")
                self.present(viewController, animated: true, completion: nil)
            })

        }))
            
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
            
        present(alert, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
