//
//  GalleryView.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class GalleryView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: GalleryViewModel
    
    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var collectionView = { ViewFactory.collectionView() }()
    
    private func setupUI() {
        
        self.addSubview(collectionView)
        
        self.collectionView.register(GalleryCollectionViewCell.self)
        
        // ToDo: Fix cells
        
//        viewModel.images.bind(to: collectionView, cellType: GalleryCollectionViewCell.self) { (cell, photo) in
//
//            cell.populateWithPhoto(photo)
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
