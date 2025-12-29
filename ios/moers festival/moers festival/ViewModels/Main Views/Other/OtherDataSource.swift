//
//  OtherDataSource.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class OtherDataSource: NSObject {
    
    // MARK: - Properties
    
    private let viewModel: OtherViewModel
    private var dataSource: UICollectionViewDiffableDataSource<Section, Row>?
    
    public init(viewModel: OtherViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - Setup
    
    public func setupDataSource(collectionView: UICollectionView) {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row> { cell, indexPath, row in
            var content = cell.defaultContentConfiguration()
            content.text = row.title
            cell.contentConfiguration = content
            cell.accessories = [.disclosureIndicator()]
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, string, indexPath in
            guard let self = self else { return }
            var content = supplementaryView.defaultContentConfiguration()
            content.text = self.viewModel.header(for: indexPath.section)
            supplementaryView.contentConfiguration = content
            supplementaryView.backgroundConfiguration = .clear()
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Row>(collectionView: collectionView) { collectionView, indexPath, row in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        update()
    }
    
    public func update() {
        
        let sections = viewModel.sections
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Row>()
        snapshot.appendSections(sections)
        
        for section in sections {
            snapshot.appendItems(section.rows, toSection: section)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
        
    }
    
    public func itemIdentifier(for indexPath: IndexPath) -> Row? {
        return dataSource?.itemIdentifier(for: indexPath)
    }
    
}
