//
//  PodestView.swift
//  Moers
//
//  Created by Lennart Fischer on 23.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class PodestView: UIView {

    lazy var placeView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    private let firstPole = PoleView(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        placeView.addArrangedSubview(<#T##view: UIView##UIView#>)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.firstPole.backgroundColor = UIColor.lightGray
            
        }
        
    }

}

class PoleView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.heightAnchor.constraint(equalToConstant: 60)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
