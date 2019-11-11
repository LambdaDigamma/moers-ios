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
import MMAPI
import MMUI

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
    @IBOutlet weak var editButton: DesignableButton!
    @IBOutlet weak var historyButton: DesignableButton!
    
    public var selectedEntry: Entry? { didSet { selectedEntry(selectedEntry) } }
    
    private var entryManager: EntryManagerProtocol!
    
    init(entryManager: EntryManagerProtocol) {
        self.entryManager = entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
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
        self.editButton.addTarget(self, action: #selector(editEntry), for: .touchUpInside)
        self.historyButton.addTarget(self, action: #selector(showHistory), for: .touchUpInside)
        
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
        
        self.editButton.isHidden = true
        self.historyButton.isHidden = true
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
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
        
        if let update = entry.updatedAt {
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
    
    @objc private func editEntry() {
        
        let viewController = EntryOnboardingOverviewViewController(entryManager: entryManager)
        
        guard let entry = selectedEntry else { return }
        
        viewController.overviewType = .edit(entry: entry)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc private func showHistory() {
        
        let viewController = EntryHistoryViewController()
        
        guard let entry = selectedEntry else { return }
        
        viewController.entry = entry
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    public func setEntryManager(_ entryManager: EntryManagerProtocol) {
        self.entryManager = entryManager
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

extension DetailEntryViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        self.topSeparator.backgroundColor = theme.decentColor
        self.buttonSeparator.backgroundColor = theme.decentColor
        self.addressSeparator.backgroundColor = theme.decentColor
        self.openingHoursSeparator.backgroundColor = theme.decentColor
        self.tagSeparator.backgroundColor = theme.decentColor
        self.callButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
        self.callButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
        self.callButton.setTitleColor(theme.backgroundColor, for: .normal)
        self.websiteButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
        self.websiteButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .highlighted)
        self.websiteButton.setTitleColor(theme.backgroundColor, for: .normal)
        self.tagsListView.backgroundColor = UIColor.clear
        self.tagsListView.tagBackgroundColor = theme.accentColor
        self.tagsListView.textColor = theme.backgroundColor
        self.tagsListView.removeIconLineColor = theme.backgroundColor
        self.lastUpdateLabel.textColor = theme.decentColor
        self.infoLabel.textColor = theme.decentColor
        self.editButton.setBackgroundColor(color: theme.decentColor, forState: .normal)
        self.editButton.setBackgroundColor(color: theme.decentColor.darker(by: 10)!, forState: UIControl.State.selected)
        self.editButton.alpha = 0.75
        self.editButton.setTitleColor(theme.backgroundColor, for: .normal)
        self.historyButton.setBackgroundColor(color: theme.decentColor, forState: .normal)
        self.historyButton.setBackgroundColor(color: theme.decentColor.darker(by: 10)!, forState: UIControl.State.selected)
        self.historyButton.alpha = 0.75
        self.historyButton.setTitleColor(theme.backgroundColor, for: .normal)
        
        let labels: [UILabel] = [self.addressHeaderLabel,
                                 self.streetLabel,
                                 self.placeLabel,
                                 self.countryLabel,
                                 self.openingHoursHeaderLabel,
                                 self.mondayHeaderLabel,
                                 self.mondayLabel,
                                 self.tuesdayHeaderLabel,
                                 self.tuesdayLabel,
                                 self.wednesdayHeaderLabel,
                                 self.wednesdayLabel,
                                 self.thursdayHeaderLabel,
                                 self.thursdayLabel,
                                 self.fridayHeaderLabel,
                                 self.fridayLabel,
                                 self.saturdayHeaderLabel,
                                 self.saturdayLabel,
                                 self.otherHeaderLabel,
                                 self.otherLabel,
                                 self.phoneHeaderLabel,
                                 self.phoneLabel,
                                 self.websiteHeaderLabel,
                                 self.websiteLabel,
                                 self.tagLabel]
        
        for label in labels {
            label.textColor = theme.color
        }
        
    }
    
}
