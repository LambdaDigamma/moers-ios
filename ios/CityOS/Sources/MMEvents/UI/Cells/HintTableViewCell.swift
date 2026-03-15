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
    
    public var image: UIImage? {
        didSet {
            self.iconImageView.image = image
            self.iconImageView.tintColor = .secondaryLabel
        }
    }
    
    private var hintLabel = { ViewFactory.label() }()
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
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
        
        self.contentView.addSubview(iconImageView)
        self.contentView.addSubview(hintLabel)
        
        self.hintLabel.translatesAutoresizingMaskIntoConstraints = false
        self.hintLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
        self.hintLabel.numberOfLines = 0
        self.hintLabel.textAlignment = .center
        
        self.iconImageView.contentMode = .scaleAspectFit
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            hintLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 4),
            hintLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            hintLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -4),
            
            iconImageView.trailingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -8),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
#if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
#endif
        self.hintLabel.textColor = UIColor.secondaryLabel
        self.iconImageView.tintColor = .secondaryLabel
        
    }
    
}

#endif
