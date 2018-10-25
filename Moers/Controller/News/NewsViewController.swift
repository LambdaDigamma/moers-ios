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
import FeedKit
import SafariServices

class NewsViewController: UIViewController, NewsManagerDelegate {
    
    private let cellIdentifier = "tweet"
    
    private var tweets: [TWTRTweet] = []
    private var items: [RSSFeedItem] = []
    
    private lazy var collectionView = { ViewFactory.collectionView() }()
    
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
    
    private let segmentedControl = UISegmentedControl(items: ["Presse", "Sozial"])
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupHeader()
        
        self.loadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.shared.logOpenedNews()
        
        self.reloadData()
        
    }
    
    private func setupUI() {
        
        self.title = String.localized("NewsTitle")
        
        self.view.addSubview(collectionView)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        
        let layout = WaterfallLayout()
        
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 16.0
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: "newsCell")
        
    }
    
    private func setupConstraints() {
        
        let constraints = [collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           collectionView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.collectionView.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    private func setupHeader() {
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 30 + 8 + 8))
        
        ThemeManager.default.apply(theme: Theme.self, to: segmentedControl) { themeable, theme in
            themeable.tintColor = theme.accentColor
        }
        
        segmentedControl.frame = CGRect(x: 10, y: 8, width: self.view.frame.width - 2 * 10, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(selectedSegment), for: .valueChanged)
        containerView.addSubview(segmentedControl)
        
        tableView.tableHeaderView = containerView
        
    }
    
    private func loadData() {
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            NewsManager.shared.delegate = self
            NewsManager.shared.getTweets()
            
        }
        
        NewsManager.shared.getRheinischePost { (error, feed) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let feed = feed else { return }
            
            self.items += feed.items ?? []
            self.items.sort(by: { ($0.pubDate ?? Date()) > ($1.pubDate ?? Date()) })
            self.collectionView.reloadData()
            
        }
        
        NewsManager.shared.getLokalkompass { (error, feed) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let feed = feed else { return }
            
            self.items += feed.items ?? []
            self.items.sort(by: { ($0.pubDate ?? Date()) > ($1.pubDate ?? Date()) })
            self.collectionView.reloadData()
            
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
    
    @objc private func selectedSegment() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
        } else {
            
        }
        
    }

    var numberOfColumns: Int {
        
        if view.traitCollection.horizontalSizeClass == .compact {
            return 1
        } else {
            return 2
        }
        
    }
    
}

extension NewsViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(items.count)
        
        return items.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCollectionViewCell
        
        cell.feedItem = items[indexPath.item]
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let url = URL(string: items[indexPath.item].link ?? "") else { return }
        
        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
        svc.configuration.entersReaderIfAvailable = true
        self.present(svc, animated: true, completion: nil)
        
    }
    
}

extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension NewsViewController: WaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return WaterfallLayout.automaticSize
        
    }
    
    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        return WaterfallLayout.Layout.waterfall(column: numberOfColumns)
    }
    
}
