//
//  DashboardCovidCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class DashboardCovidCardView: CardView {
    
    private lazy var titleLabel: UILabel = { ViewFactory.label() }()
    public lazy var landkreisIncidenceLabel: UILabel = { ViewFactory.label() }()
    public lazy var countyNameLabel: UILabel = { ViewFactory.label() }()
    
    public var viewModel: CovidIncidenceViewModel? {
        didSet {
            if let viewModel = viewModel {
                landkreisIncidenceLabel.text = viewModel.countyIncidence
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(titleLabel)
        self.addSubview(landkreisIncidenceLabel)
        self.addSubview(countyNameLabel)
        
        self.setupUI()
        self.setupAccessibility()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.titleLabel.text = "7 Tage Inzidenz - Covid 19"
        self.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        
        self.landkreisIncidenceLabel.font = UIFont.systemFont(ofSize: 40, weight: .bold)
        
    }
    
    private func setupAccessibility() {
        
        accessibilityElements = []
        
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = "Covid 19"
        self.accessibilityLabel = "Overview of the current covid 19 incidence at your location:"
//        self.accessibilityHint = String.localized("DashboardAction")
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            landkreisIncidenceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            landkreisIncidenceLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
        ]
        
        constraints.forEach { $0.priority = UILayoutPriority.required }
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: self)
        
    }
    
}

extension DashboardCovidCardView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        
        self.applyBaseStyling(theme: theme)
        
        self.titleLabel.textColor = theme.color
        
    }
    
}
