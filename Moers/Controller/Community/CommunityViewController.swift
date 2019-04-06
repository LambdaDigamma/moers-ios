//
//  CommunityViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import MMAPI

struct CommunityDashboardPanel {
    
    var title: String
    var image: UIImage
    var action: (() -> Void)?
    
}

class CommunityViewController: UIViewController, UICollectionViewDataSource {

    private let identifier = "wrapper"
    
    public lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 16.0
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.register(CommunityCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
        
    }()
    
    private var panels: [CommunityDashboardPanel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("CommunityTitle")
        
        self.panels = [CommunityDashboardPanel(title: String.localized("Events"), image: #imageLiteral(resourceName: "calendar").withRenderingMode(.alwaysTemplate), action: showEvents),
                       CommunityDashboardPanel(title: String.localized("LeaderboardTitle"), image: #imageLiteral(resourceName: "trophy").withRenderingMode(.alwaysTemplate), action: showLeaderboard),
                       CommunityDashboardPanel(title: String.localized("AddStoreTitle"), image: #imageLiteral(resourceName: "shop").withRenderingMode(.alwaysTemplate), action: showAddShop)]
        
        self.view.addSubview(collectionView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    private func setupConstraints() {
        
        let constraints = [collectionView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           collectionView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           collectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           collectionView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.collectionView.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    private func showEvents() {
        
        push(viewController: EventViewController.self)
        
    }
    
    private func showLeaderboard() {
        
        if UserManager.shared.loggedIn {
            push(viewController: LeaderboardViewController.self)
        } else {
            self.present(LoginViewController(), animated: true, completion: nil)
        }
        
    }
    
    private func showAddShop() {
        
        push(viewController: AddShopViewController.self)
        
    }
    
    private func push(viewController: UIViewController.Type) {
        
        let vc = viewController.init()
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return panels.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! CommunityCollectionViewCell
        
        let panel = panels[indexPath.row]
        
        cell.imageView.image = panel.image
        cell.titleLabel.text = panel.title
        
        return cell
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
    }
    
}

extension CommunityViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (collectionView.frame.width - 3.0 * 16.0) / CGFloat(numberOfColumns)
        
        return CGSize(width: width, height: width)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let action = panels[indexPath.item].action
        
        action?()
        
    }
    
    var numberOfColumns: Int {
        
        if view.traitCollection.horizontalSizeClass == .compact {
            return 2
        } else {
            return 4
        }
        
    }
    
}
