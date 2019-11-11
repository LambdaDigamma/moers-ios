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
import MMUI

class NewsViewController: UIViewController, NewsManagerDelegate {
    
    private let cellIdentifier = "tweet"
    
    private var newsItems: [NewsItem] = []
    
    private var tweets: [TWTRTweet] = []
    private var items: [RSSFeedItem] = []
    
    private lazy var collectionView = { ViewFactory.collectionView() }()
    
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
        
        self.view.addSubview(collectionView)
        
        let layout = WaterfallLayout()
        
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 16.0
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NewsCollectionViewCell.self, forCellWithReuseIdentifier: "newsCell")
        collectionView.register(TweetCollectionViewCell.self, forCellWithReuseIdentifier: "tweetCell")
        
    }
    
    private func setupConstraints() {
        
        let constraints = [collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           collectionView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func loadData() {
        
        newsItems = []
        
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
            
            self.newsItems.append(contentsOf: feed.items ?? [])
            self.newsItems.sort(by: { ($0.date > $1.date ) })
            
            self.collectionView.reloadData()
            
            self.items += feed.items ?? []
            
        }
        
        NewsManager.shared.getNRZ { (error, feed) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let feed = feed else { return }
            
            self.newsItems.append(contentsOf: feed.items ?? [])
            self.newsItems.sort(by: { ($0.date > $1.date ) })
            
            self.collectionView.reloadData()
            
            self.items += feed.items ?? []
            
        }
        
    }
    
    func receivedTweets(tweets: [TWTRTweet]) {
        
        self.newsItems.append(contentsOf: tweets)
        self.newsItems.sort(by: { ($0.date > $1.date ) })
        self.tweets = tweets
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
        }
        
    }
    
    public func reloadData() {
        self.collectionView.reloadData()
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
        
        return newsItems.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let newsItem = newsItems[indexPath.row] as? RSSFeedItem {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "newsCell", for: indexPath) as! NewsCollectionViewCell
            
            cell.feedItem = newsItem
            
            return cell
            
        } else if let newsItem = newsItems[indexPath.row] as? TWTRTweet {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tweetCell", for: indexPath) as! TweetCollectionViewCell

            cell.tweetView.showBorder = false
            cell.tweetView.showActionButtons = false
            
            cell.tweetView.configure(with: newsItem)
            
            return cell
            
        }
        
        return UICollectionViewCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let newsItem = newsItems[indexPath.item] as? RSSFeedItem {
            
            guard let url = URL(string: newsItem.link ?? "") else { return }
            
            let svc = SFSafariViewController(url: url)
            svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
            svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
            svc.configuration.entersReaderIfAvailable = true
            svc.delegate = self
            self.present(svc, animated: true) {
                
                self.navigationItem.largeTitleDisplayMode = .never
                
            }
            
        }
        
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

extension NewsViewController: SFSafariViewControllerDelegate {
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
//        self.navigationItem.largeTitleDisplayMode = .always
        
    }
    
}

extension NewsViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        self.view.backgroundColor = theme.backgroundColor
        self.collectionView.backgroundColor = theme.backgroundColor
        
        self.reloadData()
        
    }
    
}
