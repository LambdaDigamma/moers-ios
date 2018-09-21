//
//  FilterTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class FilterTableViewCell: UITableViewCell {

    lazy var filterImageView: UIImageView = { ViewFactory.imageView() }()
    lazy var branchLabel: UILabel = { ViewFactory.label() }()
    lazy var closeButton: UIButton = { ViewFactory.button() }()
    
    var onButtonClick: ((UITableViewCell) -> Void)?
    
    @objc private func close(_ sender: UIButton) {
        
        onButtonClick?(self)
        
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.contentView.addSubview(filterImageView)
        self.contentView.addSubview(branchLabel)
        self.contentView.addSubview(closeButton)
        
        self.setupConstraints()
        self.setupUI()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.filterImageView.image = #imageLiteral(resourceName: "filter")
        self.closeButton.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        self.closeButton.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        
    }
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [filterImageView.leftAnchor.constraint(equalTo: margins.leftAnchor),
                           filterImageView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 4),
                           filterImageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -4),
                           filterImageView.widthAnchor.constraint(equalTo: filterImageView.heightAnchor),
                           branchLabel.topAnchor.constraint(equalTo: margins.topAnchor),
                           branchLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
                           branchLabel.leftAnchor.constraint(equalTo: filterImageView.rightAnchor, constant: 8),
                           closeButton.topAnchor.constraint(equalTo: margins.topAnchor, constant: 4),
                           closeButton.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: -4),
                           closeButton.leftAnchor.constraint(equalTo: branchLabel.rightAnchor, constant: 8),
                           closeButton.rightAnchor.constraint(equalTo: margins.rightAnchor),
                           closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor
            themeable.branchLabel.textColor = theme.color
            
        }
        
    }
    
}
