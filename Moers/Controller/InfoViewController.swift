//
//  InfoViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 18.02.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MessageUI

class InfoViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBAction func composeMail(_ sender: UIBarButtonItem) {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["moersapp@lambdadigamma.com"])
            mail.setSubject("Rückmeldung zur Moers-App")
            
            present(mail, animated: true)
            
        } else {
            
            let alert = UIAlertController(title: "Feedback fehlgeschlagen", message: "Du hast scheinbar keine Email-Accounts auf deinem Gerät eingerichtet.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: { (action) in
                
                alert.dismiss(animated: true, completion: nil)
                
            }))
            
            present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
}
