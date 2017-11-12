//
//  DetailBikeChargingStationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 11.11.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class DetailBikeChargingStationViewController: UIViewController {

    @IBOutlet weak var callButton: DesignableButton!
    @IBOutlet weak var websiteButton: DesignableButton!
    
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var sundayLabel: UILabel!
    @IBOutlet weak var feastdayLabel: UILabel!
    
    @IBOutlet weak var phoneLabel: UILabel!
    
    var selectedBikeChargingStation: BikeChargingStation? {
        
        didSet {
            
            if selectedBikeChargingStation?.phone == nil {
                
                callButton.isEnabled = false
                callButton.alpha = 0.5
                
            }
            
            websiteButton.isEnabled = false
            websiteButton.alpha = 0.5
            
            guard let charger = selectedBikeChargingStation else { return }
            
            mondayLabel.text = charger.openingHours.monday
            tuesdayLabel.text = charger.openingHours.tuesday
            wednesdayLabel.text = charger.openingHours.wednesday
            thursdayLabel.text = charger.openingHours.thursday
            fridayLabel.text = charger.openingHours.friday
            saturdayLabel.text = charger.openingHours.saturday
            sundayLabel.text = charger.openingHours.sunday
            feastdayLabel.text = charger.openingHours.feastday
            
            let tel = charger.phone?.absoluteString.replacingOccurrences(of: "telprompt://", with: "+")
            
            if var normalizedPhone = tel {
                
                normalizedPhone.insert(" ", at: normalizedPhone.index(normalizedPhone.startIndex, offsetBy: 3))
                normalizedPhone.insert(" ", at: normalizedPhone.index(normalizedPhone.startIndex, offsetBy: 9))
                
                if normalizedPhone != "" {
                    
                    phoneLabel.text = normalizedPhone
                    
                }
                
            } else {
                
                phoneLabel.text = "n/v"
                
            }
            
            streetLabel.text = "\(charger.street)"
            placeLabel.text = "\(charger.postcode) Moers"
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}
