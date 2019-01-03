//
//  OtherViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 19.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MessageUI
import Alertift

class OtherViewController: UIViewController, MFMailComposeViewControllerDelegate {

    private let standardCellIdentifier = "standard"
    private let accountCellIdentifier = "account"
    private var backgroundColor: UIColor = .clear
    private var textColor: UIColor = .clear
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: UITableView.Style.grouped)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: standardCellIdentifier)
        tableView.register(AccountTableViewCell.self, forCellReuseIdentifier: accountCellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
        
    }()
    
    lazy var data: [Section] = {
        
        return [/*Section(title: "",
                        rows: [AccountRow(title: "Account", action: showAccount)]),*/
                /*Section(title: "Daten",
                        rows: [NavigationRow(title: "Eintrag hinzufügen", action: showAddEntry)]),*/
                Section(title: String.localized("SettingsTitle"),
                        rows: [NavigationRow(title: String.localized("SettingsTitle"), action: showSettings)]),
                Section(title: "Info",
                        rows: [NavigationRow(title: String.localized("AboutTitle"), action: showAbout),
                               NavigationRow(title: String.localized("Feedback"), action: showFeedback),
                               NavigationRow(title: "Version: \(Bundle.main.releaseVersionNumber ?? "?") (\(Bundle.main.buildVersionNumber ?? "?"))", action: nil)]),
                Section(title: String.localized("Legal"),
                        rows: [NavigationRow(title: String.localized("TandC"), action: showTaC),
                               NavigationRow(title: String.localized("PrivacyPolicy"), action: showPrivacy),
                               NavigationRow(title: String.localized("Licences"), action: showLicences)])]
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("OtherTabItem")
        
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        AnalyticsManager.shared.logOpenedOther()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            themeable.textColor = theme.color
            themeable.backgroundColor = theme.backgroundColor
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
        }
        
    }
    
    // MARK: - Row Action
    
    private func showAccount() {
        
        if API.shared.token == nil {
            
            self.present(LoginViewController(), animated: true, completion: nil)
            
        } else {
            
            self.navigationController?.pushViewController(AccountViewController(), animated: true)
            
        }
        
    }
    
    private func showAddEntry() {
        
        if EntryManager.shared.entryStreet != nil || EntryManager.shared.entryLat != nil {
            
            Alertift.alert(title: "Daten übernehmen?", message: "Beim letzten Mal wurde der Vorgang nicht abgeschlossen und Daten wurden zwischen gespeichert. Möchtest Du diese übernehmen?")
                .titleTextColor(textColor)
                .messageTextColor(textColor)
                .buttonTextColor(textColor)
                .backgroundColor(backgroundColor)
                .action(Alertift.Action.cancel("Nein"), handler: { (action, i, textFields) in
                    
                    EntryManager.shared.resetData()
                    
                    self.push(viewController: EntryOnboardingLocationMenuViewController.self)
                    
                })
                .action(.default("Ja"), isPreferred: true, handler: { (action, i, textFields) in
                    
                    self.push(viewController: EntryOnboardingLocationMenuViewController.self)
                    
                })
                .show()
            
        } else {
            push(viewController: EntryOnboardingLocationMenuViewController.self)
        }
        
    }
    
    private func showNonValidData() {
        push(viewController: EntryValidationViewController.self)
    }
    
    private func showSettings() {
        push(viewController: SettingsViewController.self)
    }
    
    private func showAbout() {
        push(viewController: AboutViewController.self)
    }
    
    private func showFeedback() {
        
        if MFMailComposeViewController.canSendMail() {
            
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["meinmoers@lambdadigamma.com"])
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
    
    private func showTaC() {
        push(viewController: TandCViewController.self)
    }
    
    private func showPrivacy() {
        push(viewController: PrivacyViewController.self)
    }
    
    private func showLicences() {
        push(viewController: LicensesViewController.self)
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}

extension OtherViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return data.count
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return data[section].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data[section].rows.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            cell = tableView.dequeueReusableCell(withIdentifier: standardCellIdentifier)!
            
            cell.textLabel?.text = navigationRow.title
            
            cell.accessoryType = .disclosureIndicator
            
        } else {
            
            let _ = data[indexPath.section].rows[indexPath.row] as? AccountRow
            
            let accountCell = tableView.dequeueReusableCell(withIdentifier: accountCellIdentifier) as! AccountTableViewCell
            
            accountCell.update()
            
            API.shared.getUser { (error, user) in
                
                guard let user = user else { return }
                
                UserManager.shared.register(user)
                
                OperationQueue.main.addOperation {
                    accountCell.update()
                }
                
            }
            
            cell = accountCell
            
        }
        
        cell.selectionStyle = .none
        
        ThemeManager.default.apply(theme: Theme.self, to: cell) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.textLabel?.textColor = theme.color
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let accountRow = data[indexPath.section].rows[indexPath.row] as? AccountRow {
            
            accountRow.action?()
            
        } else if let navigationRow = data[indexPath.section].rows[indexPath.row] as? NavigationRow {
            
            navigationRow.action?()
            
        }
        
    }
    
}
