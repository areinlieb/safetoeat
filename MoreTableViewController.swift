//
//  MsecoreTableViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/13/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import CoreData
import Parse
import MessageUI

class MoreTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
        
    var sections: [Section] = SectionsData().getSectionsFromData()
    
    let appStoreAppID = "1224454708"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView(frame: .zero)

    }
    
    @IBAction func unwindToMore(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToWelcome(segue: UIStoryboardSegue) {
    }
    
    func logout() {
        
        let alert = UIAlertController(title: "Change email", message: "Are you sure you want to change your email?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { (action: UIAlertAction!) in
            
            //PFUser.logOut()
            
            //delete saved email in core data
            let fetchRequest:NSFetchRequest<User> = User.fetchRequest()
            
            do {
                
                let results = try DatabaseController.getContext().fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as [User] {
                        DatabaseController.getContext().delete(result)
                    }
                }
            } catch {
                print("Couldn't fetch results")
            }
            
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

    func appRating() {
        
        let alert = UIAlertController(title: "Rate SafetoEat", message:"If you like our app, please help other pregnant families to eat safer.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil) }))

        alert.addAction(UIAlertAction(title: "Rate it now", style: .default, handler: { (action: UIAlertAction!) in
            
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + self.appStoreAppID), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func inviteFriends(sender:UIView){
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIImage(named: "app icon with bubble sushi.png")
        
        UIGraphicsEndImageContext()
        
        let subject = "SafeToEat for iPhone"
        let textToShare = "The best way to check pregnancy safe foods"
        
        if let myWebsite = URL(string: "itms-apps://itunes.apple.com/app/id" + self.appStoreAppID) {
            
            let objectsToShare = [subject, textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.setValue(subject, forKey: "Subject")
            
            //Excluded Activities
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.assignToContact, UIActivityType.addToReadingList, UIActivityType.copyToPasteboard, UIActivityType.openInIBooks, UIActivityType.postToFlickr, UIActivityType.postToVimeo, UIActivityType.postToWeibo, UIActivityType.postToTencentWeibo,UIActivityType.print, UIActivityType.saveToCameraRoll,  UIActivityType(rawValue: "com.apple.reminders.RemindersEditorExtension"),UIActivityType(rawValue: "com.apple.mobilenotes.SharingExtension")]
        
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
            
        }
    
    }
    
    func sendEmailFeedback() {
     
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@safetoeatfood.com"])
            mail.setSubject("SafeToEat: Feedback")
            mail.setMessageBody("<p>We'd love to hear from you. Please tell us how we can make SafeToEat better for everyone!</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func sendEmailRequestFood() {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["support@safetoeatfood.com"])
            mail.setSubject("SafeToEat: Food Request")
            mail.setMessageBody("<p>We're sorry you couldn't find what you were looking for. Please tell us the food you'd like us to add.</p>", isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MoreTableViewCell
    
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        cell.imageView?.image = sections[indexPath.section].icon[indexPath.row]
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section, indexPath.row) {
            
            case (0,0):
                appRating()
                break
            case (0,1):
                inviteFriends(sender: self.tableView)
                break
            case (1,0):
                guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Glossary") as? GlossaryViewController else {
                    print("Could not instantiate view controller with identifier of type SecondViewController")
                    return
                }
                self.navigationController?.pushViewController(vc, animated:true)
                break
            case (2,0):
                sendEmailRequestFood()
                break
            case (2,1):
                sendEmailFeedback()
                break
            case (2,2):
                guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Legal") as? LegalViewController else {
                    print("Could not instantiate view controller with identifier of type SecondViewController")
                    return
                }
                self.navigationController?.pushViewController(vc, animated:true)
                break
            case (3,0):
                logout()
                break
            default: break
        
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
