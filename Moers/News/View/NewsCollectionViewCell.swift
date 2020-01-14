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
import MMUI

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
            
            titleLabel.text = feedItem.title?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let url = feedItem.enclosure?.attributes?.url {
                
                if url.lowercased().contains("nrz") {
                    descriptionLabel.text = date.beautify() + " • " + "NRZ"
                } else if url.lowercased().contains("rp") {
                    descriptionLabel.text = date.beautify() + " • " + "RP Online"
                }
                
            }
            
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
                           imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                           imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                           titleLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                           titleLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -4),
                           descriptionLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10),
                           descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10),
                           descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10),
                           blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                           blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           blurView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -10)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        blurView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 12.0)
        imageView.roundCorners(corners: [.allCorners], radius: 12.0)
    }
    
}

extension NewsCollectionViewCell: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        if theme.presentationStyle == .light {
            self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        } else {
            self.blurView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        
        self.cornerRadius = 12.0
        self.backgroundColor = theme.cardBackgroundColor
        self.titleLabel.textColor = theme.color
        self.descriptionLabel.textColor = theme.color
        self.imageView.tintColor = theme.color
        self.imageView.image = self.imageView.image?.tinted(color: theme.color)
        
        if theme.cardShadow {
            
            self.clipsToBounds = false
            self.shadowColor = UIColor.lightGray
            self.shadowOpacity = 0.6
            self.shadowRadius = 10.0
            self.imageView.roundCorners(corners: [.allCorners], radius: 12.0)
            self.shadowOffset = CGSize(width: 0, height: 0)
            
        } else {
            
            self.clipsToBounds = false
            self.shadowColor = UIColor.lightGray
            self.shadowOpacity = 0.0
            self.shadowRadius = 0.0
            self.shadowOffset = CGSize(width: 0, height: 0)
            
        }
        
    }
    
}
