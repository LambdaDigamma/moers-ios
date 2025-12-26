//
//  CardCollectionViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 07.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI

class CardCollectionViewController: UIViewController, UICollectionViewDataSource {

    private let identifier = "wrapper"
    
    public lazy var collectionView: UICollectionView = {
        
        let layout = WaterfallLayout()
        
        layout.delegate = self
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        layout.minimumLineSpacing = 16.0
        layout.minimumInteritemSpacing = 16.0
        
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        collectionView.register(WrapperCardCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        return collectionView
        
    }()
    
    public var isPullToRefreshEnabled = false {
        didSet {
            if isPullToRefreshEnabled {
                let refreshControl = UIRefreshControl()
                refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
                collectionView.refreshControl = refreshControl
            } else {
                collectionView.refreshControl = nil
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(collectionView)
        
        self.setupConstraints()
        self.setupTheming()
        
    }

    var views: [UIView] = []
    
    public func registerCardViews(_ cardViews: [UIView]) {
        
        self.views = cardViews
        
        self.collectionView.reloadData()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
                           collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           collectionView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        self.view.backgroundColor = UIColor.systemBackground
        self.collectionView.backgroundColor = UIColor.systemBackground
    }

    @objc public func refresh() {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return views.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! WrapperCardCollectionViewCell
        
        cell.view = views[indexPath.row]
        
        return cell
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        
    }
    
}

extension CardCollectionViewController: UICollectionViewDelegate {
    
    var numberOfColumns: Int {
        
        if view.traitCollection.horizontalSizeClass == .compact {
            return 1
        } else {
            return 2
        }
        
    }
    
}

extension CardCollectionViewController: WaterfallLayoutDelegate {
    
    func collectionView(_ collectionView: UICollectionView, layout: WaterfallLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return WaterfallLayout.automaticSize
        
    }
    
    func collectionViewLayout(for section: Int) -> WaterfallLayout.Layout {
        return WaterfallLayout.Layout.waterfall(column: numberOfColumns)
    }
    
}
