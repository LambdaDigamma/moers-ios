//
//  LeaderboardRankingTableViewCell.swift
//  Moers
//
//  Created by Lennart Fischer on 23.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class LeaderboardRankingTableViewCell: UITableViewCell {

    private lazy var rankingView: LeaderboardRankingView = {
        
        let rankingView = LeaderboardRankingView()
        
        rankingView.translatesAutoresizingMaskIntoConstraints = false
        
        return rankingView
        
    }()
    
    var ranking: UserRanking? {
        didSet {
            rankingView.ranking = ranking
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(rankingView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [rankingView.topAnchor.constraint(equalTo: self.topAnchor),
                           rankingView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           rankingView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           rankingView.bottomAnchor.constraint(equalTo: self.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.backgroundColor = theme.backgroundColor.darker(by: 5)
            
        }
        
    }

}
