//
//  ContentDrawerView.swift
//  Moers
//
//  Created by GitHub Copilot on 27.12.24.
//

import UIKit
import SwiftUI
import TagListView
import Core

public class ContentDrawerView: UIView {
    
    lazy var gripperView = { CoreViewFactory.blankView() }()
    lazy var searchBar = { CoreViewFactory.searchBar() }()
    lazy var topSeparatorView = { CoreViewFactory.blankView() }()
    lazy var bottomSeparatorView = { CoreViewFactory.blankView() }()
    lazy var tagListView = { CoreViewFactory.tagListView() }()
    
    lazy var collectionView: UICollectionView = {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .systemBackground
        cv.contentInsetAdjustmentBehavior = .never
        return cv
    }()
    
    var headerSectionHeightConstraint: NSLayoutConstraint!
    var gripperTopConstraint: NSLayoutConstraint!
    
    private let headerSectionHeight: CGFloat = 68.0
    
    init() {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(gripperView)
        self.addSubview(searchBar)
        self.addSubview(tagListView)
        self.addSubview(topSeparatorView)
        self.addSubview(bottomSeparatorView)
        self.addSubview(collectionView)
        
        // Setup gripper
        gripperView.layer.cornerRadius = 2.5
        gripperView.backgroundColor = UIColor.lightGray
        
        // Setup separators
        topSeparatorView.backgroundColor = UIColor.lightGray
        topSeparatorView.alpha = 0.75
        bottomSeparatorView.backgroundColor = UIColor.clear
        
        // Setup search bar
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.isTranslucent = true
        searchBar.backgroundColor = UIColor.clear
        searchBar.placeholder = String(localized: "Where do you want to go?", bundle: .module)
        
        // Setup tag list
        tagListView.enableRemoveButton = true
        tagListView.paddingX = 12
        tagListView.paddingY = 7
        tagListView.marginX = 10
        tagListView.marginY = 7
        tagListView.removeIconLineWidth = 2
        tagListView.removeButtonIconSize = 7
        tagListView.textFont = UIFont.boldSystemFont(ofSize: 10)
        tagListView.cornerRadius = 10
        tagListView.backgroundColor = UIColor.clear
    }
    
    private func setupConstraints() {
        headerSectionHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: headerSectionHeight)
        gripperTopConstraint = gripperView.topAnchor.constraint(equalTo: topAnchor, constant: 6)
        
        let constraints = [
            gripperTopConstraint,
            gripperView.centerXAnchor.constraint(equalTo: centerXAnchor),
            gripperView.heightAnchor.constraint(equalToConstant: 5),
            gripperView.widthAnchor.constraint(equalToConstant: 36),
            
            searchBar.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            headerSectionHeightConstraint,
            
            tagListView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tagListView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tagListView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tagListView.heightAnchor.constraint(equalToConstant: 20),
            
            topSeparatorView.topAnchor.constraint(equalTo: tagListView.bottomAnchor, constant: 8),
            topSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            topSeparatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            collectionView.topAnchor.constraint(equalTo: topSeparatorView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            bottomSeparatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomSeparatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparatorView.heightAnchor.constraint(equalToConstant: 0.5)
        ]
        
        NSLayoutConstraint.activate(constraints.compactMap { $0 })
    }
}
