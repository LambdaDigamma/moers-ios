//
//  DetailShopViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 22.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import SafariServices
import Crashlytics

class DetailShopViewController: UIViewController {

    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var callButton: DesignableButton!
    @IBOutlet weak var websiteButton: DesignableButton!
    @IBOutlet weak var buttonSeparator: UIView!
    @IBOutlet weak var addressHeaderLabel: UILabel!
    @IBOutlet weak var streetLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var addressSeparator: UIView!
    @IBOutlet weak var openingHoursHeaderLabel: UILabel!
    @IBOutlet weak var mondayHeaderLabel: UILabel!
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayHeaderLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayHeaderLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayHeaderLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayHeaderLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    @IBOutlet weak var saturdayHeaderLabel: UILabel!
    @IBOutlet weak var saturdayLabel: UILabel!
    @IBOutlet weak var otherHeaderLabel: UILabel!
    @IBOutlet weak var otherLabel: UILabel!
    @IBOutlet weak var openingHoursSeparator: UIView!
    @IBOutlet weak var phoneHeaderLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteHeaderLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    
    public var selectedShop: Store? { didSet { selectShop(selectedShop) } }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods

    private func setupUI() {
        
        self.callButton.setTitle(String.localized("CallAction"), for: .normal)
        self.websiteButton.setTitle(String.localized("WebsiteAction"), for: .normal)
        self.callButton.layer.cornerRadius = 8
        self.websiteButton.layer.cornerRadius = 8
        self.callButton.clipsToBounds = true
        self.websiteButton.clipsToBounds = true
        self.callButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        self.websiteButton.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        self.addressHeaderLabel.text = "Adresse"
        self.callButton.addTarget(self, action: #selector(call), for: .touchUpInside)
        self.websiteButton.addTarget(self, action: #selector(openWebsite), for: .touchUpInside)
        
        
        
        self.topSeparator.alpha = 0.5
        self.buttonSeparator.alpha = 0.5
        self.addressSeparator.alpha = 0.5
        self.openingHoursSeparator.alpha = 0.5
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.topSeparator.backgroundColor = theme.decentColor
            themeable.buttonSeparator.backgroundColor = theme.decentColor
            themeable.addressSeparator.backgroundColor = theme.decentColor
            themeable.openingHoursSeparator.backgroundColor = theme.decentColor
            themeable.callButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.callButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.callButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.websiteButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.websiteButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.websiteButton.setTitleColor(theme.backgroundColor, for: .normal)
            
            let labels: [UILabel] = [themeable.addressHeaderLabel,
                                     themeable.streetLabel,
                                     themeable.placeLabel,
                                     themeable.countryLabel,
                                     themeable.openingHoursHeaderLabel,
                                     themeable.mondayHeaderLabel,
                                     themeable.mondayLabel,
                                     themeable.tuesdayHeaderLabel,
                                     themeable.tuesdayLabel,
                                     themeable.wednesdayHeaderLabel,
                                     themeable.wednesdayLabel,
                                     themeable.thursdayHeaderLabel,
                                     themeable.thursdayLabel,
                                     themeable.fridayHeaderLabel,
                                     themeable.fridayLabel,
                                     themeable.saturdayHeaderLabel,
                                     themeable.saturdayLabel,
                                     themeable.otherHeaderLabel,
                                     themeable.otherLabel,
                                     themeable.phoneHeaderLabel,
                                     themeable.phoneLabel,
                                     themeable.websiteHeaderLabel,
                                     themeable.websiteLabel]
            
            for label in labels {
                label.textColor = theme.color
            }
            
        }
        
    }
    
    private func selectShop(_ shop: Store?) {

        guard let shop = shop else { return }
        
        self.streetLabel.text = shop.street + " " + shop.houseNumber
        self.placeLabel.text = shop.postcode + " " + shop.place
        self.countryLabel.text = "Deutschland"
        
        self.mondayLabel.text = shop.monday ?? ""
        self.tuesdayLabel.text = shop.tuesday ?? ""
        self.wednesdayLabel.text = shop.wednesday ?? ""
        self.thursdayLabel.text = shop.thursday ?? ""
        self.fridayLabel.text = shop.friday ?? ""
        self.saturdayLabel.text = shop.saturday ?? ""
        self.otherLabel.text = shop.other ?? ""
        
        if let url = shop.url, url != "" {
            self.websiteLabel.text = url
        } else {
            self.websiteLabel.text = "n/v"
            self.websiteButton.isEnabled = false
            self.websiteButton.alpha = 0.25
        }
        
        if let phone = shop.phone, phone != "" {
            self.phoneLabel.text = phone
        } else {
            self.phoneLabel.text = "n/v"
            self.callButton.isEnabled = false
            self.callButton.alpha = 0.25
        }
        
        Answers.logCustomEvent(withName: "Open Shop Website", customAttributes:
            ["name": shop.name,
             "branch": shop.branch])
        
    }
    
    @objc private func call() {
        
        guard let shop = selectedShop else { return }
        guard let phone = shop.phone?.replacingOccurrences(of: " ", with: "") else { return }
        guard let url = URL(string: "telprompt://" + phone) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        
    }
    
    @objc private func openWebsite() {
        
        guard let shop = selectedShop else { return }
        guard var urlString = shop.url else { return }
        
        if !urlString.starts(with: "https://") && !urlString.starts(with: "http://") {
            urlString = "http://" + urlString
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
        self.present(svc, animated: true, completion: nil)
        
    }
    
    static func fromStoryboard() -> DetailShopViewController {
        
        let storyboard = UIStoryboard(name: "DetailViewControllers", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: "DetailShopViewController") as! DetailShopViewController
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
