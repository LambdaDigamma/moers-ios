//
//  TweetCollectionViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 23.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import TwitterKit
import Gestalt

class TweetCollectionViewCell: UICollectionViewCell, TWTRTweetViewDelegate {
    
    lazy var tweetView: TWTRTweetView = {
        
        let tweetView = TWTRTweetView(tweet: nil, style: TWTRTweetViewStyle.compact)
        
        tweetView.translatesAutoresizingMaskIntoConstraints = false
        tweetView.delegate = self
        
        return tweetView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupTheming()
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.contentView.addSubview(tweetView)
        
        self.clipsToBounds = false
        
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.tweetView.theme = theme.statusBarStyle == .lightContent ? .dark : .light
            themeable.tweetView.backgroundColor = theme.cardBackgroundColor
            
            themeable.cornerRadius = 12.0
            themeable.backgroundColor = theme.cardBackgroundColor
            
            if theme.cardShadow {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.6
                themeable.shadowRadius = 10.0
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
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints = [tweetView.leftAnchor.constraint(equalTo: margins.leftAnchor, constant: 0),
                           tweetView.rightAnchor.constraint(equalTo: margins.rightAnchor, constant: 0),
                           tweetView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8),
                           tweetView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTap image: UIImage, with imageURL: URL) {
        
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTapVideoWith videoURL: URL) {
        
    }
    
    
}
