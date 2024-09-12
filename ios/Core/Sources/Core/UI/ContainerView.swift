//
//  ContainerView.swift
//  
//
//  Created by Lennart Fischer on 11.03.20.
//

import UIKit

public class ContainerView: UIView {
    
    public let contentView: UIView
    
    public init(contentView: UIView, edgeInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)) {
        
        self.contentView = contentView
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(frame: .zero)
        
        self.addSubview(contentView)
        
        let constraints = [
            contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: edgeInsets.top),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: edgeInsets.left),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -edgeInsets.right),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -edgeInsets.bottom)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
