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
import StoreKit
import GoogleMobileAds
import Firebase

class MoreTableViewController: UITableViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver {
        
    var sections: [Section] = SectionsData().getSectionsFromData()
    
    let appStoreAppID = "1229895485"

    let defaults = UserDefaults.standard
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-6303297723397278/4158106644"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var activeProduct: SKProduct?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let restoreButton = UIBarButtonItem(title: "Restore", style: .plain, target: self, action: #selector(MoreTableViewController.restorePurchases))
        navigationItem.rightBarButtonItem = restoreButton

        tableView.tableFooterView = UIView(frame: .zero)
        
        let productIdentifiers: Set<String> = ["removeads"]
        let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
        
        SKPaymentQueue.default().add(self)

    }
    
    override func viewDidAppear(_ animated: Bool) {

        if !defaults.bool(forKey: "removeAds") {
            adBannerView.load(GADRequest())
        }

    }
    
    @IBAction func unwindToMore(segue: UIStoryboardSegue) {
    }
    
    @IBAction func unwindToWelcome(segue: UIStoryboardSegue) {
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        //print ("Loaded products")
        for product in response.products {
            activeProduct = product
        }
        
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            
            switch (transaction.transactionState) {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                //print("Purchased")

                defaults.set(true, forKey: "removeAds")
                
                let alert = UIAlertController(title: "Thank you", message: "Please restart the app to remove ads.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {
                    (alertAction: UIAlertAction!) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
            
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                //print("Purchased")
                
                defaults.set(true, forKey: "removeAds")
    
                let alert = UIAlertController(title: "Thank you", message: "Your purchases have been restored. Please restart the app to remove ads.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: {
                    (alertAction: UIAlertAction!) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                present(alert, animated: true, completion: nil)
                
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                break
            }
            
        }
        
    }
    
    func restorePurchases () {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        
        //print("Banner loaded successfully")
        
        let translateTransform = CGAffineTransform(translationX: 0, y: -bannerView.bounds.size.height)
        bannerView.transform = translateTransform
        
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        
        bannerView.frame = CGRect(x:0.0, y: screenHeight - bannerView.frame.size.height - (self.tabBarController?.tabBar.frame.height)!, width: bannerView.frame.size.width, height: bannerView.frame.size.height)
        
        if !defaults.bool(forKey: "removeAds") {
            view.superview?.addSubview(bannerView)
        }
        
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        
        //print("Fail to receive ads")
        //print(error)
    }

    func appRating() {
        
        let alert = UIAlertController(title: "Rate this app", message:"If you like our app, please help other pregnant families to eat safer.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil) }))

        alert.addAction(UIAlertAction(title: "Rate it now", style: .default, handler: { (action: UIAlertAction!) in
            
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id" + self.appStoreAppID + "?action=write-review"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func inviteFriends(sender:UIView){
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIImage(named: "frame_3.png")
        
        UIGraphicsEndImageContext()
        
        let subject = "Pregnancy Food: Guide & Recipes for iPhone"
        let textToShare = "The best way to check pregnancy safe foods and find delicious recipes:"
        
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
    
    func removeAds() {
        
        if let activeProduct = activeProduct {
            
            //print("buying \(activeProduct.productIdentifier)")
            
            let payment = SKPayment(product: activeProduct)
            SKPaymentQueue.default().add(payment)
            
            
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
        
        cell.textLabel?.textColor = UIColor(red: 60.0/255.0, green: 67.0/255.0, blue: 80.0/255.0, alpha: 1.0)
        cell.textLabel?.text = sections[indexPath.section].items[indexPath.row]
        
        cell.imageView?.tintColor = UIColor(red: 60.0/255.0, green: 67.0/255.0, blue: 80.0/255.0, alpha: 1.0)
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
                    //print("Could not instantiate view controller with identifier of type SecondViewController")
                    return
                }
                self.navigationController?.pushViewController(vc, animated:true)
                break
            case (2,0):
                sendEmailFeedback()
                break
            case (2,1):
                guard let vc = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "Legal") as? LegalViewController else {
                    //print("Could not instantiate view controller with identifier of type SecondViewController")
                    return
                }
                self.navigationController?.pushViewController(vc, animated:true)
                break
            case (3,0):
                removeAds()
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
