//
//  NewsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 24.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TwitterKit

class NewsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NewsManagerDelegate {
    
    private let cellIdentifier = "tweet"
    
    private var tweets: [TWTRTweet] = []
    
    private lazy var tableView: UITableView = {
        
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
        
        return tableView
        
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
        self.loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logOpenedNews()
        
        self.reloadData()
        
    }
    
    private func setupUI() {
        
        self.title = String.localized("NewsTitle")
        
        self.view.addSubview(self.tableView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.tableView.backgroundColor = theme.backgroundColor
            themeable.tableView.separatorColor = theme.separatorColor
            
        }
        
    }
    
    private func loadData() {
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            NewsManager.shared.delegate = self
            NewsManager.shared.getTweets()
            
        }
        
    }
    
    func receivedTweets(tweets: [TWTRTweet]) {
        
        self.tweets = tweets
        
        DispatchQueue.main.async {
            
            self.tableView.reloadData()
            
        }
        
    }
    
    public func reloadData() {
        self.tableView.reloadData()
    }
    
    @objc private func refresh() {
        
        UIView.animate(withDuration: 1, animations: {
            
            self.tableView.refreshControl?.endRefreshing()
            
        }) { (_) in
            
            self.loadData()
            
        }
        
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return tweets.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweet") as! TweetTableViewCell
        
        cell.tweetView.showBorder = false
        cell.tweetView.showActionButtons = false
        
        cell.tweetView.configure(with: tweets[indexPath.row])
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
