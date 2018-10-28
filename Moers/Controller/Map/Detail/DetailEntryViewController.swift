//
//  DetailEntryViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 11.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import SafariServices
import Crashlytics
import TagListView

class DetailEntryViewController: UIViewController {
    
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
    @IBOutlet weak var tagSeparator: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagsListView: TagListView!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    public var selectedEntry: Entry? { didSet { selectedEntry(selectedEntry) } }
    
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
        self.tagSeparator.alpha = 0.5
        
        self.tagsListView.paddingX = 12
        self.tagsListView.paddingY = 7
        self.tagsListView.marginX = 10
        self.tagsListView.marginY = 7
        self.tagsListView.removeIconLineWidth = 2
        self.tagsListView.removeButtonIconSize = 7
        self.tagsListView.textFont = UIFont.boldSystemFont(ofSize: 10)
        self.tagsListView.cornerRadius = 10
        self.tagsListView.backgroundColor = UIColor.clear
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.topSeparator.backgroundColor = theme.decentColor
            themeable.buttonSeparator.backgroundColor = theme.decentColor
            themeable.addressSeparator.backgroundColor = theme.decentColor
            themeable.openingHoursSeparator.backgroundColor = theme.decentColor
            themeable.tagSeparator.backgroundColor = theme.decentColor
            themeable.callButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.callButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.callButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.websiteButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.websiteButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
            themeable.websiteButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.tagsListView.backgroundColor = UIColor.clear
            themeable.tagsListView.tagBackgroundColor = theme.accentColor
            themeable.tagsListView.textColor = theme.backgroundColor
            themeable.tagsListView.removeIconLineColor = theme.backgroundColor
            themeable.lastUpdateLabel.textColor = theme.decentColor
            themeable.infoLabel.textColor = theme.decentColor
            
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
                                     themeable.websiteLabel,
                                     themeable.tagLabel]
            
            for label in labels {
                label.textColor = theme.color
            }
            
        }
        
    }

    private func selectedEntry(_ entry: Entry?) {
        
        guard let entry = entry else { return }
        
        self.streetLabel.text = entry.street + " " + entry.houseNumber
        self.placeLabel.text = entry.postcode + " " + entry.place
        self.countryLabel.text = "Deutschland"
        
        self.tagsListView.removeAllTags()
        self.tagsListView.addTags(entry.tags)
        
        self.mondayLabel.text = entry.monday ?? ""
        self.tuesdayLabel.text = entry.tuesday ?? ""
        self.wednesdayLabel.text = entry.wednesday ?? ""
        self.thursdayLabel.text = entry.thursday ?? ""
        self.fridayLabel.text = entry.friday ?? ""
        self.saturdayLabel.text = entry.saturday ?? ""
        self.otherLabel.text = entry.other ?? ""
        
        if let url = entry.url, url != "" {
            self.websiteLabel.text = url
        } else {
            self.websiteLabel.text = "n/v"
            self.websiteButton.isEnabled = false
            self.websiteButton.alpha = 0.25
        }
        
        if let phone = entry.phone, phone != "" {
            self.phoneLabel.text = phone
        } else {
            self.phoneLabel.text = "n/v"
            self.callButton.isEnabled = false
            self.callButton.alpha = 0.25
        }
        
        if let update = entry.updateDate {
            self.lastUpdateLabel.text = "Letzte Änderung: \(update.beautify(format: "dd.MM.yyyy hh:mm"))"
        } else {
            self.lastUpdateLabel.text = "Letzte Änderung: nicht bekannt"
        }
        
        Answers.logCustomEvent(withName: "Open Entry Website", customAttributes:
            ["name": entry.name])
        
    }
    
    @objc private func call() {
        
        guard let entry = selectedEntry else { return }
        guard let phone = entry.phone?.replacingOccurrences(of: " ", with: "") else { return }
        guard let url = URL(string: "telprompt://" + phone) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        
    }
    
    @objc private func openWebsite() {
        
        guard let entry = selectedEntry else { return }
        guard var urlString = entry.url else { return }
        
        if !urlString.starts(with: "https://") && !urlString.starts(with: "http://") {
            urlString = "http://" + urlString
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
        self.present(svc, animated: true, completion: nil)
        
    }
    
    static func fromStoryboard() -> DetailEntryViewController {
        
        let storyboard = UIStoryboard(name: "DetailViewControllers", bundle: nil)
        
        return storyboard.instantiateViewController(withIdentifier: "DetailEntryViewController") as! DetailEntryViewController
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
public func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
