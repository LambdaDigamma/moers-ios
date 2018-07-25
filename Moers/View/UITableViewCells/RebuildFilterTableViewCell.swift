//
//  RebuildFilterTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 18.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class RebuildFilterTableViewCell: UITableViewCell {

    lazy var filterImageView: UIImageView = {
        
        let imageView = UIImageView(image: #imageLiteral(resourceName: "filter"))
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
        
    }()
    
    lazy var branchLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }()
    
    lazy var closeButton: UIButton = {
        
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(#imageLiteral(resourceName: "close"), for: .normal)
        button.addTarget(self, action: #selector(close(_:)), for: .touchUpInside)
        
        return button
        
    }()
    
    var onButtonClick: ((UITableViewCell) -> Void)?
    
    @objc private func close(_ sender: UIButton) {
        
        onButtonClick?(self)
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(filterImageView)
        self.addSubview(branchLabel)
        self.addSubview(closeButton)
        
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [filterImageView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           filterImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
                           filterImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
                           filterImageView.widthAnchor.constraint(equalTo: filterImageView.heightAnchor),
                           branchLabel.topAnchor.constraint(equalTo: self.topAnchor),
                           branchLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           branchLabel.leftAnchor.constraint(equalTo: filterImageView.rightAnchor, constant: 8),
                           closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 4),
                           closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -4),
                           closeButton.leftAnchor.constraint(equalTo: branchLabel.rightAnchor, constant: 8),
                           closeButton.rightAnchor.constraint(equalTo: self.rightAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
