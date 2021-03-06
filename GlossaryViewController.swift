//
//  GlossaryViewController.swift
//  SafeToEat
//
//  Created by Alex Reinlieb on 4/23/17.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit

class GlossaryViewController: UIViewController {

    @IBOutlet var glossaryText: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        
        let rtfPath = Bundle.main.url(forResource: "Glossary", withExtension: "rtf")!
        var d : NSDictionary? = nil
        let attributedStringWithRtf = try! NSAttributedString(
            url: rtfPath,
            options: [NSDocumentTypeDocumentAttribute : NSRTFTextDocumentType],
            documentAttributes: &d)
        self.glossaryText.attributedText = attributedStringWithRtf
        
        glossaryText.isScrollEnabled = false
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        glossaryText.isScrollEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
