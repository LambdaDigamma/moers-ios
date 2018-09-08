//
//  DebugViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 07.09.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import UserNotifications

class DebugViewController: UIViewController {
    
    lazy var rubbishItemsTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: UIFont.Weight.regular)
        textView.isEditable = false
        textView.isSelectable = false
        
        return textView
        
    }()
    
    lazy var notificationItemsTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: UIFont.Weight.regular)
        textView.isEditable = false
        textView.isSelectable = false
        
        return textView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
        RubbishManager.shared.loadItems(completion: { (items) in
            
            self.rubbishItemsTextView.text = "Collections: \(items.count)\n\n"
            self.rubbishItemsTextView.text = self.rubbishItemsTextView.text + items.map { $0.date + " " + RubbishWasteType.localizedForCase($0.type) }.joined(separator: "\n")
            
        }, all: false)
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            
            DispatchQueue.main.async {
                
                self.notificationItemsTextView.text = "Notifications: \(requests.count)\n\n"
                self.notificationItemsTextView.text = self.notificationItemsTextView.text + requests.map { $0.identifier.replacingOccurrences(of: "RubbishReminder-", with: "") }.reversed().joined(separator: "\n")
                
            }
            
        }
        
    }
    
    private func setupUI() {
        
        self.title = "Debug"
        
        self.view.addSubview(rubbishItemsTextView)
        self.view.addSubview(notificationItemsTextView)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [rubbishItemsTextView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           rubbishItemsTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 8),
                           rubbishItemsTextView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
                           rubbishItemsTextView.widthAnchor.constraint(equalTo: notificationItemsTextView.widthAnchor),
                           notificationItemsTextView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           notificationItemsTextView.leftAnchor.constraint(equalTo: rubbishItemsTextView.rightAnchor),
                           notificationItemsTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -8),
                           notificationItemsTextView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.rubbishItemsTextView.textColor = theme.color
            themeable.rubbishItemsTextView.backgroundColor = theme.backgroundColor
            themeable.notificationItemsTextView.textColor = theme.color
            themeable.notificationItemsTextView.backgroundColor = theme.backgroundColor
        }
        
    }
    
}
