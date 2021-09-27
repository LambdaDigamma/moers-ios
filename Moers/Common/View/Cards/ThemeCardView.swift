//
//  ThemeCardView.swift
//  Moers
//
//  Created by Lennart Fischer on 20.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class ThemeCardView: TitleCardView {
    
    public var theme: ApplicationTheme? {
        didSet {
            
            guard let theme = theme else { return }
            
            titleLabel.text = theme.identifier

            colorList.arrangedSubviews[0].backgroundColor = theme.navigationBarColor
            colorList.arrangedSubviews[1].backgroundColor = theme.backgroundColor
            colorList.arrangedSubviews[2].backgroundColor = theme.accentColor
            colorList.arrangedSubviews[3].backgroundColor = theme.decentColor
            
        }
    }

    lazy var colorList: UIStackView = {
        
        let stackView = UIStackView(arrangedSubviews: [])
        
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = UIStackView.Alignment.fill
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(colorList)
        
        colorList.addArrangedSubview(buildColorView(color: UIColor.white))
        colorList.addArrangedSubview(buildColorView(color: UIColor.white))
        colorList.addArrangedSubview(buildColorView(color: UIColor.white))
        colorList.addArrangedSubview(buildColorView(color: UIColor.white))
        
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            colorList.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            colorList.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            colorList.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            colorList.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func buildColorView(color: UIColor) -> UIView {
        
        let view = ColorView()
        
        view.backgroundColor = color
        view.layer.borderWidth = 2
        view.layer.cornerRadius = 2
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: view)
        
        return view
        
    }
    
}

class ColorView: UIView {
    
}

extension ColorView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        self.layer.borderColor = theme.decentColor.cgColor
    }
    
}
