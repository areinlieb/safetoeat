//
//  LegalWelcomeViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 3/24/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class LegalWelcomeViewController: UIViewController {
    
    @IBOutlet var legalText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        let rtfPath = Bundle.main.url(forResource: "LegalSample", withExtension: "rtf")!
        var d : NSDictionary? = nil
        let attributedStringWithRtf = try! NSAttributedString(
            url: rtfPath,
            options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType],
            documentAttributes: &d)
        self.legalText.attributedText = attributedStringWithRtf
        
        legalText.isScrollEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        legalText.isScrollEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
