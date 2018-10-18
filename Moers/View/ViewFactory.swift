//
//  ViewFactory.swift
//  Moers
//
//  Created by Lennart Fischer on 26.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import TextFieldEffects
import WebKit
import TagListView

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
    
    static func paddingLabel() -> PaddingLabel {
        
        let label = PaddingLabel()
        
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
    
    static func textField() -> HoshiTextField {
        
        let textField = HoshiTextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
        
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
    
    static func cardView() -> CardView {
        
        let cardView = CardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }
    
    static func tableView() -> UITableView {
        
        let tableView = UITableView()
        
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
    
    static func onboardingProgressView() -> OnboardingProgressView {
        
        let progressView = OnboardingProgressView()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
        
    }
    
    static func tagListView() -> TagListView {
        
        let tagListView = TagListView()
        
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        tagListView.paddingX = 12
        tagListView.paddingY = 7
        tagListView.marginX = 10
        tagListView.marginY = 7
        tagListView.removeIconLineWidth = 2
        tagListView.removeButtonIconSize = 7
        tagListView.textFont = UIFont.boldSystemFont(ofSize: 10)
        tagListView.cornerRadius = 10
        tagListView.backgroundColor = UIColor.clear
        
        return tagListView
        
    }
    
}
