//
//  HintTableViewCell.swift
//  MMUI
//
//  Created by Lennart Fischer on 12.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public class HintTableViewCell: UITableViewCell {
    
    public static var identifier = "hintCell"
    
    public var hint: String? {
        didSet {
            self.hintLabel.text = hint
        }
    }
    
    private var hintLabel = { ViewFactory.label() }()
    
    // MARK: - Inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.contentView.addSubview(hintLabel)
        
        self.hintLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        self.hintLabel.numberOfLines = 0
        self.hintLabel.textAlignment = .left
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            hintLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 4),
            hintLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -4)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
#if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
#endif
        self.hintLabel.textColor = UIColor.secondaryLabel
        
    }
    
}

#endif
