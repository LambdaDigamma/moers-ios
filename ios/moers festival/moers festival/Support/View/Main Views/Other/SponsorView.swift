//
//  SponsorView.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class SponsorView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: SponsorViewModel
    
    init(viewModel: SponsorViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupBinding()
        self.setupConstraints()
        self.setupTheming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var collectionViewLayout: UICollectionViewLayout = {
        
        let layout = UICollectionViewFlowLayout()
        
        layout.headerReferenceSize = CGSize(width: bounds.width, height: 50)
        layout.sectionHeadersPinToVisibleBounds = true
        
        return layout
        
    }()
    
    private lazy var collectionView = { ViewFactory.collectionView(layout: collectionViewLayout) }()
    
    private func setupUI() {
        
        self.addSubview(collectionView)
        
        self.collectionView.registerSupplementaryView(HeaderCollectionViewCell.self, forKind: UICollectionView.elementKindSectionHeader)
        
    }
    
    private func setupBinding() {
        
        // todo: fix sponsors
        
//        viewModel.sponsors.bind(to: collectionView, cellType: SponsorCollectionViewCell.self, using: SponsorBinder()) { (cell, item) in
//
//            cell.imageView.image = item.image
//
//        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.systemBackground
        self.collectionView.backgroundColor = UIColor.systemBackground
        
    }
    
    public func setCollectionViewDelegate(_ delegate: UICollectionViewDelegate) {
        self.collectionView.delegate = delegate
    }
    
}
