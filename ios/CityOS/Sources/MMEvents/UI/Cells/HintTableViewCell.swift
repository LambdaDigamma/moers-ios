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
            self.imageView?.image = image
            self.imageView?.tintColor = .secondaryLabel
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
        self.hintLabel.textAlignment = .center
        
        self.imageView?.contentMode = .scaleAspectFit
        
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
        
        if let imageView = imageView {
            NSLayoutConstraint.activate([
                imageView.widthAnchor.constraint(equalToConstant: 40),
                imageView.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
    }
    
    private func setupTheming() {
        
#if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
#endif
        self.hintLabel.textColor = UIColor.secondaryLabel
        self.imageView?.tintColor = .secondaryLabel
        
    }
    
}

#endif
