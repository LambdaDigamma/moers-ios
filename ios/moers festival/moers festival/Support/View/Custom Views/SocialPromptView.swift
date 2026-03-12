//
//  SocialPromptView.swift
//  moers festival
//
//  Created by Lennart Fischer on 23.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit

class SocialPromptView: UIView {
    
    private lazy var hashtagImageView: UIImageView = { ViewFactory.imageView() }()
    
    init() {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.addSubview(hashtagImageView)
        self.hashtagImageView.image = UIImage(systemName: "number")?.withRenderingMode(.alwaysTemplate)
        self.hashtagImageView.contentMode = .scaleAspectFit
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            hashtagImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            hashtagImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hashtagImageView.widthAnchor.constraint(equalToConstant: 30),
            hashtagImageView.heightAnchor.constraint(equalTo: hashtagImageView.widthAnchor),
            hashtagImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.hashtagImageView.tintColor = UIColor.label
        
    }
    
    
}
