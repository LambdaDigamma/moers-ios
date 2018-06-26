//
//  DetailShopViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import Crashlytics

class DetailShopViewController: UIViewController {

    @IBOutlet weak var callButton: DesignableButton!
    @IBOutlet weak var websiteButton: DesignableButton!
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var postCodeLabel: UILabel!
    
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    
    @IBAction func call(_ sender: DesignableButton) {
        
        guard let shop = selectedShop else { return }
        
        Answers.logCustomEvent(withName: "Call Shop", customAttributes: ["name": shop.name, "branch": shop.branch])
        
        if let url = shop.phone, UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
        
    }
    
    @IBAction func openWebsite(_ sender: DesignableButton) {
        
        guard let shop = selectedShop else { return }
        
        if let url = shop.url, UIApplication.shared.canOpenURL(url) {
            
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
        
    }
    
    var selectedShop: Shop? {
        
        didSet {
            
            if selectedShop?.url == nil {
                
                websiteButton.isEnabled = false
                websiteButton.alpha = 0.5
                
            }
            
            if selectedShop?.phone == nil {
                
                callButton.isEnabled = false
                callButton.alpha = 0.5
                
            }
            
            guard let shop = selectedShop else { return }
            
            Answers.logCustomEvent(withName: "Open Shop Website", customAttributes: ["name": shop.name, "branch": shop.branch])
            
            mondayLabel.text = shop.openingTimes.createOpeningString(from: .monday)
            tuesdayLabel.text = shop.openingTimes.createOpeningString(from: .tuesday)
            wednesdayLabel.text = shop.openingTimes.createOpeningString(from: .wednesday)
            thursdayLabel.text = shop.openingTimes.createOpeningString(from: .thursday)
            fridayLabel.text = shop.openingTimes.createOpeningString(from: .friday)
            saturdayLabel.text = shop.openingTimes.createOpeningString(from: .saturday)
            
            if shop.openingTimes.other != "" {
                otherLabel.text = shop.openingTimes.other
            } else {
                otherLabel.text = "n/v"
            }
            
            let tel = shop.phone?.absoluteString.replacingOccurrences(of: "telprompt://", with: "+")
            
            if var normalizedPhone = tel {
                
                normalizedPhone.insert(" ", at: normalizedPhone.index(normalizedPhone.startIndex, offsetBy: 3))
                normalizedPhone.insert(" ", at: normalizedPhone.index(normalizedPhone.startIndex, offsetBy: 9))
                
                if normalizedPhone != "" {
                    
                    phoneLabel.text = normalizedPhone
                    
                }
                
            } else {
                
                phoneLabel.text = "n/v"
                
            }
            
            let website = shop.url?.absoluteString.replacingOccurrences(of: "http://www.", with: "")
            
            if website != nil {
                
                websiteLabel.text = website
                
            } else {
                
                websiteLabel.text = "n/v"
                
            }
            
            streetLabel.text = "\(shop.street) \(shop.houseNumber)"
            postCodeLabel.text = "\(shop.postcode) Moers"
            
            Answers.logCustomEvent(withName: "Detail - Shop", customAttributes: ["name": shop.name, "branch": shop.branch])
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
    }
    
}
