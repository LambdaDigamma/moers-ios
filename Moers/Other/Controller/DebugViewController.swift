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
import MMUI
import Combine
import Resolver
import RubbishFeature

class DebugViewController: UIViewController {
    
    @LazyInjected var rubbishService: RubbishService
    
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
    
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            
            DispatchQueue.main.async {
                
                self.notificationItemsTextView.text = "Notifications: \(requests.count)\n\n"
                self.notificationItemsTextView.text += requests.map {
                    $0.identifier.replacingOccurrences(of: "RubbishReminder-", with: "")
                }
                .reversed()
                .joined(separator: "\n")
                
            }
            
        }
        
        guard let street = rubbishService.rubbishStreet else {
            return
        }
        
        let pickupItems = rubbishService.loadRubbishPickupItems(for: street)
        
        pickupItems
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (_: Subscribers.Completion<RubbishLoadingError>) in
                
            }, receiveValue: { (items: [RubbishPickupItem]) in
                
                self.rubbishItemsTextView.text = "Collections: \(items.count)\n\n"
                self.rubbishItemsTextView.text += items.map {
                    $0.date.format(format: "dd.MM.yyyy") + " " + $0.type.title
                }
                .joined(separator: "\n")
                
            })
            .store(in: &cancellables)
        
    }
    
    private func setupUI() {
        
        self.title = "Debug"
        
        self.view.addSubview(rubbishItemsTextView)
        self.view.addSubview(notificationItemsTextView)
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            rubbishItemsTextView.topAnchor.constraint(equalTo: self.safeTopAnchor),
            rubbishItemsTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8),
            rubbishItemsTextView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor),
            rubbishItemsTextView.widthAnchor.constraint(equalTo: notificationItemsTextView.widthAnchor),
            notificationItemsTextView.topAnchor.constraint(equalTo: self.safeTopAnchor),
            notificationItemsTextView.leadingAnchor.constraint(equalTo: rubbishItemsTextView.trailingAnchor),
            notificationItemsTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            notificationItemsTextView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }

    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
}

extension DebugViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.view.backgroundColor = theme.backgroundColor
        self.rubbishItemsTextView.textColor = theme.color
        self.rubbishItemsTextView.backgroundColor = theme.backgroundColor
        self.notificationItemsTextView.textColor = theme.color
        self.notificationItemsTextView.backgroundColor = theme.backgroundColor
    }
    
}
