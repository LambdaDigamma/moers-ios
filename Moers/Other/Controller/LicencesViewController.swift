//
//  LicencesViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class LicensesViewController: UIViewController {
    
    lazy var textView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isSelectable = false
        textView.isEditable = false
        
        return textView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(textView)
        self.title = String.localized("Licences")
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
        setupConstraints()
        
        let license = buildLicenseString()
        
        textView.text = license
        
    }
    
    private func setupConstraints() {
        
        let constraints = [textView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 8),
                           textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
                           textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
                           textView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func buildLicenseString() -> String {
        
        var licenseString = ""
        
        License.loadFromPlist().map({ "\($0.framework)\n\n\($0.name)\n\n\($0.text)" }).forEach { licenseString += "\($0)\n\n" }
        
        return licenseString
        
    }
    
}

extension LicensesViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.textView.backgroundColor = theme.backgroundColor
        self.textView.textColor = theme.color
    }
    
}
