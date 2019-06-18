//
//  LeaderboardViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI
import MMUI

class LeaderboardViewController: UIViewController {

    lazy var podestView: PodestView = {
        
        let podestView = PodestView()
        
        podestView.translatesAutoresizingMaskIntoConstraints = false
        
        return podestView
        
    }()
    
    lazy var userLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.text = String.localized("UserRankingText").uppercased()
        
        return label
        
    }()
    
    lazy var userRankingView: LeaderboardRankingView = {
        
        let rankingView = LeaderboardRankingView()
        
        rankingView.translatesAutoresizingMaskIntoConstraints = false
        
        return rankingView
        
    }()
    
    lazy var topLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.text = "TOP 20"
        
        return label
        
    }()
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(LeaderboardRankingTableViewCell.self, forCellReuseIdentifier: identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableView.automaticDimension
        tableView.bounces = false
        tableView.allowsSelection = false
        
        return tableView
        
    }()
    
    var rankings: [UserRanking] = []
    
    private let identifier = "rankingCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("LeaderboardTitle")
        
        self.view.addSubview(podestView)
        self.view.addSubview(userLabel)
        self.view.addSubview(userRankingView)
        self.view.addSubview(topLabel)
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        self.loadRankings()
        
    }
    
    private func loadRankings() {
        
        RankingManager.shared.getTopRanking { (error, rankings) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let rankings = rankings else { return }
            
            self.rankings = rankings
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
        
        RankingManager.shared.getMyRanking { (error, ranking) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let ranking = ranking else { return }
            
            DispatchQueue.main.async {
                self.userRankingView.ranking = ranking
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
            
        }
        
    }

    private func setupConstraints() {
        
        let constraints = [podestView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 0),
                           podestView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                           podestView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                           podestView.heightAnchor.constraint(equalToConstant: 0),
                           userLabel.topAnchor.constraint(equalTo: self.podestView.bottomAnchor, constant: 16),
                           userLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           userLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           userRankingView.topAnchor.constraint(equalTo: userLabel.bottomAnchor, constant: 8),
                           userRankingView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           userRankingView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           topLabel.topAnchor.constraint(equalTo: userRankingView.bottomAnchor, constant: 16),
                           topLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           topLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           tableView.topAnchor.constraint(equalTo: topLabel.bottomAnchor, constant: 8),
                           tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.userRankingView.backgroundColor = theme.backgroundColor.darker(by: 5)
            themeable.topLabel.textColor = theme.color
            themeable.userLabel.textColor = theme.color
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            
        }
        
    }

}

extension LeaderboardViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as! LeaderboardRankingTableViewCell
        
        cell.ranking = rankings[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return rankings.count
        
    }
    
}
