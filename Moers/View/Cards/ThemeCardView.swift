//
//  ThemeCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class ThemeCardView: TitleCardView {
    
    public var theme: Theme? {
        didSet {
            
            guard let theme = theme else { return }
            
            colorList.addArrangedSubview(buildColorView(color: theme.navigationBarColor))
            colorList.addArrangedSubview(buildColorView(color: theme.backgroundColor))
            colorList.addArrangedSubview(buildColorView(color: theme.accentColor))
            colorList.addArrangedSubview(buildColorView(color: theme.decentColor))
            
        }
    }

    lazy var colorList: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = UIStackViewAlignment.fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(colorList)
        
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [colorList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
                           colorList.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           colorList.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           colorList.heightAnchor.constraint(equalToConstant: 30),
                           colorList.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func buildColorView(color: UIColor) -> UIView {
        
        let view = UIView()
        
        view.backgroundColor = color
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 2
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        ThemeManager.default.apply(theme: Theme.self, to: view) { (themeable, theme) in
            themeable.layer.borderColor = theme.decentColor.cgColor
        }
        
        return view
        
    }
    
}
