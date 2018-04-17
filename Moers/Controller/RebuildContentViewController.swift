//
//  RebuildContentViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Pulley

class RebuildContentViewController: UIViewController, PulleyDrawerViewControllerDelegate {

    // MARK: - UI
    
    lazy var gripperView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.lightGray
        
        return view
        
    }()
    
    lazy var searchBar: UISearchBar = {
        
        let searchBar = UISearchBar()
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.searchBarStyle = .minimal
        searchBar.barStyle = .default
        searchBar.isTranslucent = true
        searchBar.backgroundColor = UIColor.clear
        searchBar.placeholder = String.localized("SearchBarPrompt")
        
        return searchBar
        
    }()
    
    lazy var seperatorView: UIView = {
        
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.lightGray
        view.alpha = 0.75
        
        return view
        
    }()
    
    lazy var tableView: UITableView = {
        
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        return tableView
        
    }()
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(searchBar)
        self.view.addSubview(gripperView)
        self.view.addSubview(seperatorView)
        self.view.addSubview(tableView)
        
        self.setupConstraints()
        self.setupTheming()

    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let seperatorHeightConstraint = gripperView.heightAnchor.constraint(equalToConstant: 5)
        let searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 65)
        
        seperatorHeightConstraint.isActive = true
        searchBarHeightConstraint.isActive = true
        
        let constraints = [gripperView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 5),
                           gripperView.widthAnchor.constraint(equalToConstant: 36),
                           gripperView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                           searchBar.topAnchor.constraint(equalTo: self.view.topAnchor),
                           searchBar.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           searchBar.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           seperatorView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
                           seperatorView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           seperatorView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           seperatorView.heightAnchor.constraint(equalToConstant: 1)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.navigationColor
            themeable.searchBar.barTintColor = theme.accentColor
            themeable.searchBar.backgroundColor = theme.navigationColor
            
        }
        
    }
    
    // MARK: - PulleyDrawerViewControllerDelegate
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat {
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all
    }
    
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        
    }
    
}
