//
//  OnboardingOverviewNotice.swift
//  Moers
//
//  Created by Lennart Fischer on 01.01.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit

import Core

class OnboardingOverviewNotice: UIView {
    
    private lazy var noticeLabel: UILabel = { CoreViewFactory.label() }()
    
    public var notice: String = "" {
        didSet {
            noticeLabel.text = notice
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(noticeLabel)
        self.noticeLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        self.noticeLabel.numberOfLines = 0
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            noticeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            noticeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            noticeLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            noticeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
    }
    
}

