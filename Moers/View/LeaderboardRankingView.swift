//
//  LeaderboardRankingView.swift
//  Moers
//
//  Created by Lennart Fischer on 23.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMUI

class LeaderboardRankingView: UIView {

    private lazy var userRankLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        return label
        
    }()
    
    private lazy var userNameLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        return label
        
    }()
    
    private lazy var userPointsLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        
        return label
        
    }()
    
    public var ranking: UserRanking? {
        didSet {
            guard let ranking = ranking else { return }
            userRankLabel.text = "\(ranking.rank)."
            userNameLabel.text = ranking.name
            userPointsLabel.text = "\(ranking.points)"
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(userRankLabel)
        self.addSubview(userNameLabel)
        self.addSubview(userPointsLabel)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [userRankLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
                           userRankLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           userRankLabel.widthAnchor.constraint(equalToConstant: 40),
                           userRankLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
                           userNameLabel.topAnchor.constraint(equalTo: userRankLabel.topAnchor),
                           userNameLabel.leftAnchor.constraint(equalTo: userRankLabel.rightAnchor, constant: 8),
                           userNameLabel.rightAnchor.constraint(equalTo: userPointsLabel.leftAnchor, constant: -8),
                           userNameLabel.bottomAnchor.constraint(equalTo: userRankLabel.bottomAnchor),
                           userPointsLabel.topAnchor.constraint(equalTo: userRankLabel.topAnchor),
                           userPointsLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           userPointsLabel.bottomAnchor.constraint(equalTo: userRankLabel.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.userRankLabel.textColor = theme.color
            themeable.userNameLabel.textColor = theme.color
            themeable.userPointsLabel.textColor = theme.color
            
        }
        
    }
    
}
