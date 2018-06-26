//
//  LicencesViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

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
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.textView.backgroundColor = theme.backgroundColor
            themeable.textView.textColor = theme.color
        }
        
        setupConstraints()
        
        let license = buildLicenseString()
        
        textView.text = license
        
    }
    
    private func setupConstraints() {
        
        let constraints = [textView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 8),
                           textView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8),
                           textView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8),
                           textView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func buildLicenseString() -> String {
        
        var licenseString = ""
        
        License.loadFromPlist().map({ "\($0.framework)\n\n\($0.name)\n\n\($0.text)" }).forEach { licenseString += "\($0)\n\n" }
        
        return licenseString
        
    }
    
}
