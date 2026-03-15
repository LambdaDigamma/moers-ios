//
//  InactiveStreamViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit

class InactiveStreamViewController: UIViewController {
    
    private lazy var layoutStack: UIStackView = { ViewFactory.stackView() }()
    private lazy var errorImage: UIImageView = { ViewFactory.imageView() }()
    private lazy var titleLabel: UILabel = { ViewFactory.label() }()
    private lazy var descriptionLabel: UILabel = { ViewFactory.label() }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.view.addSubview(layoutStack)
        self.view.addSubview(errorImage)
        
        self.layoutStack.addArrangedSubview(titleLabel)
        self.layoutStack.addArrangedSubview(descriptionLabel)
        self.layoutStack.axis = .vertical
        self.layoutStack.distribution = .fillProportionally
        self.layoutStack.alignment = .center
        
        self.errorImage.image = UIImage(named: "error_mu")
        self.errorImage.contentMode = .scaleAspectFit
        self.errorImage.clipsToBounds = true
        self.titleLabel.text = String.localized("LivestreamInactiveTitle")
        self.titleLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        self.titleLabel.textAlignment = .center
        self.descriptionLabel.text = String.localized("LivestreamInactiveDescription")
        self.descriptionLabel.numberOfLines = 0
        self.descriptionLabel.textAlignment = .center
        
    }
    
    private func setupConstraints() {
        
        let margins = self.view.readableContentGuide
        
        let constraints = [
            layoutStack.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: 60),
            layoutStack.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            layoutStack.leadingAnchor.constraint(lessThanOrEqualTo: margins.leadingAnchor),
            layoutStack.trailingAnchor.constraint(lessThanOrEqualTo: margins.trailingAnchor),
            errorImage.widthAnchor.constraint(equalTo: errorImage.heightAnchor, multiplier: 57/71),
            errorImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            errorImage.bottomAnchor.constraint(equalTo: layoutStack.topAnchor, constant: -16),
            errorImage.widthAnchor.constraint(lessThanOrEqualToConstant: 120)
        ]
        
        self.layoutStack.setCustomSpacing(8, after: titleLabel)
        self.layoutStack.setCustomSpacing(20, after: errorImage)
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.titleLabel.textColor = UIColor.label
        self.descriptionLabel.textColor = UIColor.secondaryLabel
        
    }
    
}
