//
//  MoreTableViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class MoreTableViewController: UITableViewController {
    
    var sections: [Section] = SectionsData().getSectionsFromData()
    
    func logout() {
        
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { (action: UIAlertAction!) in
            
            PFUser.logOut()
            
            DispatchQueue.main.async(execute: { () -> Void in
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login")
                self.present(viewController, animated: true, completion: nil)
            })
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        present(alert, animated: true, completion: nil)
        
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].heading
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
    
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            logout()
            tableView.deselectRow(at: indexPath, animated: true)
            
        }
        
    }

}
