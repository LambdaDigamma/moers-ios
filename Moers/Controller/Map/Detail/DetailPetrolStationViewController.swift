//
//  DetailPetrolStationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.08.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI

class DetailPetrolStationViewController: UIViewController {

    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var priceHeaderLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressSeparator: UIView!
    @IBOutlet weak var addressHeaderLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    var selectedPetrolStation: PetrolStation? { didSet { setupPetrolStation(selectedPetrolStation) } }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupTheming()
        
    }
    
    private func setupUI() {
        
        self.priceHeaderLabel.text = String.localized("PriceHeader")
        self.addressHeaderLabel.text = String.localized("AddressHeader")
        
        self.topSeparator.alpha = 0.5
        self.addressSeparator.alpha = 0.5
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.topSeparator.backgroundColor = theme.decentColor
            themeable.addressSeparator.backgroundColor = theme.decentColor
            
            let labels: [UILabel] = [themeable.priceHeaderLabel,
                                     themeable.typeLabel,
                                     themeable.priceLabel,
                                     themeable.addressHeaderLabel,
                                     themeable.streetLabel,
                                     themeable.placeLabel,
                                     themeable.countryLabel]
            
            for label in labels {
                label.textColor = theme.color
            }
            
        }
        
    }
    
    public func setupPetrolStation(_ petrolStation: PetrolStation?) {
        
        guard let petrolStation = petrolStation else { return }
        
        self.streetLabel.text = petrolStation.street + " " + (petrolStation.houseNumber ?? "")
        self.placeLabel.text = "\(petrolStation.postCode ?? 0) \(petrolStation.place)"
        self.typeLabel.text = PetrolType.localizedForCase(PetrolManager.shared.petrolType)
        self.priceLabel.text = String(format: "%.2f€", petrolStation.price ?? 0)
        
    }
    
    public static func fromStoryboard() -> DetailPetrolStationViewController {
        
        let storyboard = UIStoryboard(name: "DetailViewControllers", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: "DetailPetrolStationViewController") as! DetailPetrolStationViewController
        
    }
    
}
