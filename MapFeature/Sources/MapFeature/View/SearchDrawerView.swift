//
//  SearchDrawerView.swift
//  Moers
//
//  Created by Lennart Fischer on 18.10.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TagListView
import Core

public class SearchDrawerView: UIView {
    
    lazy var searchWrapper = { CoreViewFactory.blankView() }()
    lazy var gripper = { CoreViewFactory.blankView() }()
    lazy var searchBar = { CoreViewFactory.searchBar() }()
    lazy var tagList = { CoreViewFactory.tagListView() }()
    lazy var topSeparator = { CoreViewFactory.blankView() }()
    lazy var tableView = { CoreViewFactory.tableView() }()
    
    init() {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var searchWrapperHeight: NSLayoutConstraint!
    
    private let gripperHeight: CGFloat = 5
    private let gripperWidth: CGFloat = 36
    
    private func setupUI() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
        self.setupSearchWrapper()
        self.setupSearchBar()
        self.setupTagList()
        self.setupTableView()
        self.setupTopSeparator()
        self.setupGripper()
        
    }
    
    private func setupSearchWrapper() {
        self.addSubview(searchWrapper)
        self.searchWrapper.accessibilityIdentifier = "SearchWrapper"
    }
    
    private func setupGripper() {
        self.addSubview(gripper)
        self.gripper.layer.cornerRadius = gripperHeight / 2
        self.gripper.accessibilityIdentifier = "Gripper"
    }
    
    private func setupSearchBar() {
        self.addSubview(searchBar)
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.accessibilityIdentifier = "SearchBar"
        self.searchBar.backgroundColor = UIColor.clear
        self.searchBar.placeholder = String.localized("SearchBarPrompt")
    }
    
    private func setupTagList() {
        self.addSubview(tagList)
        self.tagList.enableRemoveButton = true
        self.tagList.paddingX = 12
        self.tagList.paddingY = 7
        self.tagList.marginX = 10
        self.tagList.marginY = 7
        self.tagList.removeIconLineWidth = 2
        self.tagList.removeButtonIconSize = 7
        self.tagList.textFont = UIFont.boldSystemFont(ofSize: 10)
        self.tagList.cornerRadius = 10
        self.tagList.backgroundColor = UIColor.clear
        self.tagList.accessibilityIdentifier = "TagList"
    }
    
    private func setupTableView() {
        self.addSubview(tableView)
        self.tableView.register(SearchResultTableViewCell.self,
                                forCellReuseIdentifier: CellIdentifier.searchResultCell)
        self.tableView.register(TagTableViewCell.self,
                                forCellReuseIdentifier: CellIdentifier.tagCell)
    }
    
    private func setupTopSeparator() {
        self.addSubview(topSeparator)
        self.topSeparator.alpha = 0.5
        self.topSeparator.accessibilityIdentifier = "TopSeparator"
    }
    
    private func setupConstraints() {
        
        self.searchWrapperHeight = searchWrapper.heightAnchor.constraint(equalToConstant: 68)
        self.searchWrapperHeight.priority = .init(rawValue: 250)
        
        searchWrapperHeight.isActive = true
        
        let searchWrapperConstraints = [
            searchWrapper.topAnchor.constraint(equalTo: topAnchor),
            searchWrapper.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchWrapper.trailingAnchor.constraint(equalTo: trailingAnchor),
        ]
        
        searchWrapperConstraints.forEach { $0.priority = .defaultLow }
        
        let tagListConstraints = [
            tagList.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tagList.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            tagList.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            tagList.bottomAnchor.constraint(equalTo: searchWrapper.bottomAnchor, constant: -8)
        ]
        
        tagListConstraints.forEach { $0.priority = .init(rawValue: 500) }
        
        let constraints = [
            gripper.topAnchor.constraint(equalTo: searchWrapper.topAnchor, constant: 6),
            gripper.centerXAnchor.constraint(equalTo: centerXAnchor),
            gripper.heightAnchor.constraint(equalToConstant: gripperHeight),
            gripper.widthAnchor.constraint(equalToConstant: gripperWidth),
            searchBar.topAnchor.constraint(equalTo: searchWrapper.topAnchor, constant: 6),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            searchWrapper.bottomAnchor.constraint(equalTo: tagList.bottomAnchor, constant: 8),
            topSeparator.bottomAnchor.constraint(equalTo: tableView.topAnchor),
            topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: searchWrapper.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20)
        ]
        
        constraints.forEach { $0.priority = .defaultLow }
        
        NSLayoutConstraint.activate(tagListConstraints)
        NSLayoutConstraint.activate(searchWrapperConstraints)
        NSLayoutConstraint.activate(constraints)
        
    }
    
}

extension SearchDrawerView: Themeable {
    
    public typealias Theme = ApplicationTheme
    
    public func apply(theme: ApplicationTheme) {
        
        backgroundColor = theme.backgroundColor
        tableView.backgroundColor = theme.backgroundColor
        tableView.separatorColor = theme.separatorColor
        searchWrapper.backgroundColor = theme.backgroundColor
        gripper.backgroundColor = UIColor.lightGray
        
        topSeparator.backgroundColor = theme.decentColor
        tagList.tagBackgroundColor = theme.accentColor
        tagList.textColor = theme.backgroundColor
        tagList.removeIconLineColor = theme.backgroundColor
        
        if #available(iOS 13, *) {
            searchBar.barTintColor = .clear
            searchBar.backgroundColor = theme.backgroundColor
            searchBar.tintColor = theme.accentColor
            searchBar.searchTextField.textColor = theme.color
            searchBar.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
        } else {
            searchBar.barTintColor = .clear
            searchBar.backgroundColor = theme.backgroundColor
            searchBar.tintColor = theme.accentColor
            searchBar.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            guard let searchField = searchBar.value(forKey: "searchField") as? UITextField else { return }
            searchField.textColor = theme.color
            
        }
        
    }
    
}
