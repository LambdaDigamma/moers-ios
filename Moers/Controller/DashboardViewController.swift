//
//  DashboardViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import UserNotifications

class DashboardViewController: UIViewController {

    // MARK: - UI
    
    lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
        
    }()
    
    lazy var cardStackView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    lazy var notificationCardView: DashboardNotificationCardView = {
        
        let cardView = DashboardNotificationCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.titleLabel.text = "Was weiß ich"
        cardView.subtitleLabel.text = "Morgen um 16 Uhr..."
        
        return cardView
        
    }()
    
    lazy var rubbishCardView: DashboardRubbishCardView = {
        
        let cardView = DashboardRubbishCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    var cards: [CardView] {
        return [rubbishCardView]
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(scrollView)
        self.scrollView.addSubview(cardStackView)
        
        self.setupCards(cards)
        self.setupConstraints()
        self.setupTheming()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            if AppConfig.shared.loadData {
                self.loadData()
            }
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            
            print(requests)
            
        }
        
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                           cardStackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 16),
                           cardStackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: -16),
                           cardStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 16),
                           cardStackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -16),
                           cardStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -32)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.cards.forEach { $0.backgroundColor = theme.cardBackgroundColor }
            
        }
        
    }

    public func loadData() {
        
        RubbishManager.shared.loadItems(completion: { (items) in
            
            OperationQueue.main.addOperation {
                
                if items.count >= 3 {
                    self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                    self.rubbishCardView.itemView2.rubbishCollectionItem = items[1]
                    self.rubbishCardView.itemView3.rubbishCollectionItem = items[2]
                } else if items.count >= 2 {
                    self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                    self.rubbishCardView.itemView2.rubbishCollectionItem = items[1]
                } else if items.count >= 1 {
                    self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                }
                
            }
            
        })
        
    }
    
    public func setupCards(_ cards: [CardView]) {
        
        cards.forEach { cardStackView.addArrangedSubview($0) }
        
    }
    
}
