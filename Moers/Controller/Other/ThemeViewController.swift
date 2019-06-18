//
//  ThemeViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class ThemeViewController: CardCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String.localized("ThemeTitle")
        
        self.setupThemeCards()
        self.setupTheming()
        
        AnalyticsManager.shared.logOpenedTheme()
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    public func setupThemeCards() {
        
        let themes = Theme.all
        
        let cards = themes.map { themeCard(with: $0) }
        
        cards.forEach { $0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectedTheme(_:)))) }
        
        registerCardViews(cards)
        
    }
    
    private func themeCard(with theme: Theme) -> ThemeCardView {
        
        let cardView = ThemeCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.titleLabel.text = theme.identifier
        cardView.theme = theme
        
        return cardView
        
    }
    
    @objc private func selectedTheme(_ tapGesture: UITapGestureRecognizer) {
        
        guard let themeCardView = tapGesture.view as? ThemeCardView else { return }
        
        guard let theme = themeCardView.theme else { return }

        ThemeManager.default.theme = theme
        UserManager.shared.theme = theme
        
        AnalyticsManager.shared.logSelectedTheme(theme)
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        
        tabBarController.newsViewController.reloadData()
        
    }
    
}
