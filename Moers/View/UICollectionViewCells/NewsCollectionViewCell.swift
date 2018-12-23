//
//  NewsCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 24.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import FeedKit
import Kingfisher

class NewsCollectionViewCell: UICollectionViewCell {
    
    private lazy var titleLabel = { ViewFactory.label() }()
    private lazy var descriptionLabel = { ViewFactory.label() }()
    private lazy var imageView = { ViewFactory.imageView() }()
    private lazy var blurView = { ViewFactory.blurView() }()
    
    public var feedItem: RSSFeedItem! {
        didSet {
            
            if let enclosure = feedItem.enclosure {
                if let url = URL(string: enclosure.attributes?.url ?? "") {
                    imageView.kf.setImage(with: ImageResource(downloadURL: url))
                }
            } else {
                if let description = feedItem.description {
                    let components = description.components(separatedBy: "\"")
                    if components.count > 1 {
                        if let url = URL(string: components[1]) {
                            imageView.kf.setImage(with: ImageResource(downloadURL: url))
                        }
                    }
                }
            }
            
            let date = feedItem.pubDate ?? Date()
            
            titleLabel.text = feedItem.title
            descriptionLabel.text = date.beautify() + " • " + "RP Online"
            
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(imageView)
        self.addSubview(blurView)
        self.addSubview(titleLabel)
        self.addSubview(descriptionLabel)
        
        self.clipsToBounds = false
        self.imageView.clipsToBounds = true
        
        self.imageView.contentMode = .scaleAspectFill
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        self.descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [heightAnchor.constraint(equalToConstant: 250),
                           imageView.topAnchor.constraint(equalTo: self.topAnchor),
                           imageView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           imageView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
                           titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -4),
                           descriptionLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
                           descriptionLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
                           descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
                           blurView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           blurView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           blurView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            if theme.presentationStyle == .light {
                themeable.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
            } else {
                themeable.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            }
            
            themeable.cornerRadius = 12.0
            themeable.backgroundColor = theme.cardBackgroundColor
            themeable.titleLabel.textColor = theme.color
            themeable.descriptionLabel.textColor = theme.color
            themeable.imageView.tintColor = theme.color
            themeable.imageView.image = themeable.imageView.image?.tinted(color: theme.color)
            
            if theme.cardShadow {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.6
                themeable.shadowRadius = 10.0
                themeable.imageView.roundCorners(corners: [.allCorners], radius: 12.0)
                themeable.shadowOffset = CGSize(width: 0, height: 0)
                
            } else {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.0
                themeable.shadowRadius = 0.0
                themeable.shadowOffset = CGSize(width: 0, height: 0)
                
            }
            
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
        imageView.roundCorners(corners: [.allCorners], radius: 12.0)
    }
    
}
