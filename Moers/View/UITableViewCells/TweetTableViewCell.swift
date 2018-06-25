//
//  TweetTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TwitterKit

class TweetTableViewCell: UITableViewCell, TWTRTweetViewDelegate {
    
    lazy var tweetView: TWTRTweetView = {
        
        let tweetView = TWTRTweetView(tweet: nil, style: TWTRTweetViewStyle.compact)
        
        tweetView.translatesAutoresizingMaskIntoConstraints = false
        tweetView.theme = .dark
        tweetView.delegate = self
        
        return tweetView
        
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.backgroundColor = theme.backgroundColor
            themeable.tweetView.backgroundColor = theme.backgroundColor
        }
        
        self.addSubview(tweetView)
        
        initializeConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeConstraints() {
        
        let constraints = [tweetView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
                           tweetView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
                           tweetView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                           tweetView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTap image: UIImage, with imageURL: URL) {
        
    }
    
    func tweetView(_ tweetView: TWTRTweetView, didTapVideoWith videoURL: URL) {
        
    }
    
}
