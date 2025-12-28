//
//  EventHeaderFooterView.swift
//  MMUI
//
//  Created by Lennart Fischer on 12.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public class EventHeaderFooterView: UITableViewHeaderFooterView {
    
    public static var identifier = "headerCell"
    
    private lazy var sectionLabel = { ViewFactory.label() }()
    private lazy var moreButton = { ViewFactory.button() }()
    
    public var showMoreButton: Bool = true {
        didSet {
            moreButton.isHidden = !showMoreButton
        }
    }
    
    public var title: String = "" {
        didSet {
            sectionLabel.text = title
        }
    }
    
    public var action: (() -> ())?
    
    // MARK: - Inits
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupAccessibility()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        showMoreButton = true
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.contentView.addSubview(sectionLabel)
        self.contentView.addSubview(moreButton)
        
        self.sectionLabel.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        
        self.moreButton.setTitle(String(localized: "Show more", bundle: .module), for: .normal)
        self.moreButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        self.moreButton.addTarget(self, action: #selector(tapMoreButton), for: .touchUpInside)
        self.moreButton.titleLabel?.textAlignment = .right
        self.moreButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.moreButton.titleLabel?.minimumScaleFactor = 0.5
        
    }
    
    private func setupAccessibility() {
        
        self.sectionLabel.accessibilityIdentifier = "EventHeader.Section"
        self.moreButton.accessibilityIdentifier = "EventHeader.ShowMore"
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            sectionLabel.topAnchor.constraint(equalTo: margins.topAnchor),
            sectionLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            sectionLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            sectionLabel.trailingAnchor.constraint(equalTo: moreButton.leadingAnchor),
            moreButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            moreButton.heightAnchor.constraint(equalToConstant: 24),
            moreButton.widthAnchor.constraint(lessThanOrEqualToConstant: 100),
            moreButton.leadingAnchor.constraint(equalTo: sectionLabel.trailingAnchor),
            moreButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
#if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
#endif
        self.sectionLabel.textColor = UIColor.secondaryLabel
        self.moreButton.setTitleColor(EventPackageConfiguration.accentColor, for: .normal)
    }
    
    @objc private func tapMoreButton() {
        
        action?()
        
    }
    
}

#endif
