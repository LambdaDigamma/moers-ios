//
//  ViewFactory.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.12.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import Foundation
import MapKit
import WebKit
//import TwitterKit

struct ViewFactory {
    
    static func blankView() -> UIView {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
        
    }
    
    static func label() -> UILabel {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }
    
    static func scrollView() -> UIScrollView {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
        
    }
    
    static func map() -> MKMapView {
        
        let map = MKMapView()
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
        
    }
    
    static func imageView() -> UIImageView {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }
    
    static func button() -> UIButton {
        
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
        
    }
    
    static func roundedButton() -> UIButton {
        
        let roundedButton = button()
        
        roundedButton.layer.cornerRadius = 5
        roundedButton.setTitle("", for: .normal)
        roundedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        return roundedButton
        
    }
    
    static func stackView() -> UIStackView {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }
    
    static func webView() -> WKWebView {
        
        let webView = WKWebView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
        
    }
    
    static func tableView(with style: UITableView.Style = .plain) -> UITableView {
        
        let tableView = UITableView(frame: .zero, style: style)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.estimatedSectionHeaderHeight = UITableView.automaticDimension
        
        return tableView
        
    }
    
    static func searchBar() -> UISearchBar {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        return searchBar
        
    }
    
    static func progressView() -> UIProgressView {
        
        let progressView = UIProgressView()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
        
    }
    
    static func collectionView(layout: UICollectionViewLayout = UICollectionViewFlowLayout()) -> UICollectionView {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        return collectionView
        
    }
    
    static func blurView(style: UIBlurEffect.Style = .dark) -> UIVisualEffectView {
        
        let effect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: effect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        return blurView
        
    }
    
    static func textView() -> UITextView {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        return textView
        
    }
    
    static func ticketView(viewModel: TicketViewModel) -> TicketView {
        
        let ticketView = TicketView(viewModel: viewModel)
        
        ticketView.translatesAutoresizingMaskIntoConstraints = false
        
        return ticketView
        
    }
    
    static func paddingLabel() -> PaddingLabel {
        
        let paddingLabel = PaddingLabel()
        
        paddingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return paddingLabel
        
    }
    
//    static func tweetView(with style: TWTRTweetViewStyle = .compact) -> TWTRTweetView {
//
//        let tweetView = TWTRTweetView(tweet: nil, style: style)
//
//        tweetView.translatesAutoresizingMaskIntoConstraints = false
//
//        return tweetView
//
//    }
    
    static func playerView() -> PlayerView {
        let playerView = PlayerView()
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        return playerView
    }
    
}
