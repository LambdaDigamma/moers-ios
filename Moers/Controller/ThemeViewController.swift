//
//  ThemeViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class ThemeViewController: UIViewController {

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
    
    lazy var lightningThemeCardView: ThemeCardView = {
        
        let cardView = ThemeCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.titleLabel.text = "Lightning"
        cardView.theme = Theme.lightning
        
        return cardView
        
    }()
    
    lazy var darkThemeCardView: ThemeCardView = {
        
        let cardView = ThemeCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.titleLabel.text = "Dark"
        cardView.theme = Theme.dark
        
        return cardView
        
    }()
    
    var cards: [ThemeCardView] {
        return [lightningThemeCardView, darkThemeCardView]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("ThemeTitle")
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(cardStackView)
        
        self.setupCards(cards)
        self.setupConstraints()
        self.setupTheming()
        
        
    }
    
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
            
        }
        
    }
    
    public func setupCards(_ cards: [CardView]) {
        
        ThemeManager.default.animated = true
        
        cards.forEach { cardStackView.addArrangedSubview($0) }
        cards.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectedTheme(_:)))) }
        
    }
    
    @objc private func selectedTheme(_ tapGesture: UITapGestureRecognizer) {
        
        guard let themeCardView = tapGesture.view as? ThemeCardView else { return }
        
        guard let theme = themeCardView.theme else { return }

        ThemeManager.default.theme = theme
        
    }

}
