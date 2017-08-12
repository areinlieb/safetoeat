//
//  CoreDataViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/14/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse
import CoreData

class CoreDataViewController: UIViewController {

    @IBOutlet var backgroundImage: UIImageView!
    @IBOutlet var loadingLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    
    var counter = 0
    var timer = Timer()
    var loadingTimer = Timer()
    
    var foodCategoryTypes = [String]()
    var foodCategoryImages = [UIImage]()

    let defaults = UserDefaults.standard
    
    func animate() {
        
        backgroundImage.image = UIImage(named: "frame_\(counter).png")
        counter += 1
        
        if counter == 9 {
            
            if defaults.object(forKey: "email") != nil {
                
                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                self.present(viewController, animated: true, completion: nil)
                
            } else {

                let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Welcome")
                self.present(viewController, animated: true, completion: nil)
                
            }
        }
        
    }
    
    override func viewDidLoad() {
 
        super.viewDidLoad()
        
        //initialize lastUpdated to default value if it doesn't exist yet
        if defaults.object(forKey: "lastUpdated") == nil {
            let tempDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())
            defaults.set(tempDate, forKey: "lastUpdated")
            defaults.set(tempDate, forKey: "lastUpdated2")
        }

        let queueTimer = DispatchQueue(label: "timerQueue", qos: DispatchQoS.userInteractive)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(CoreDataViewController.animate), userInfo: nil, repeats: true)

        queueTimer.async {
            self.animate()
        }
        
        progressView.progress = 0.0
        loadingTimer = Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(progressDisplay), userInfo: nil, repeats: true)

        //load data from parse into core data
        
        let queueLoadFood = DispatchQueue(label: "loadFoodQueue")
        queueLoadFood.async {
            LoadData.loadFood()
        }
        
    }
    
    func progressDisplay() {

        switch progressView.progress {
        case 0.0:
            loadingLabel.text = "Loading Food..."
            break
        case 1.0:
            loadingLabel.text = "Yummy!"
            break
        default: break
        }
        
        progressView.progress += 0.005
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
