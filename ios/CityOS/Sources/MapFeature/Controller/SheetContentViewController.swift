//
//  SheetContentViewController.swift
//  CityOS
//
//  Created by Lennart Fischer on 31.01.26.
//

import UIKit

class SheetContentViewController: UIViewController {

    lazy var tabBar = {
        let tabBar = UITabBar()
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        return tabBar
    }()
    
    public var tabBarHeight: CGFloat {
        return tabBar.bounds.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
    }

    public func setupUI() {
        
        self.view.addSubview(tabBar)
        
        let appearance = UITabBarAppearance()

        appearance.backgroundEffect = .none
        appearance.configureWithOpaqueBackground()
        
        tabBar.items = [
            UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1),
            UITabBarItem(tabBarSystemItem: .favorites, tag: 2)
        ]
        
        tabBar.isTranslucent = true
        tabBar.backgroundColor = .clear
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        let constraints = [
            tabBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
