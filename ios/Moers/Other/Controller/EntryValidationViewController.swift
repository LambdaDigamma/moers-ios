//
//  EntryValidationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import MapFeature
import SwiftUI

class EntryValidationViewController: UIViewController {

    public var coordinator: DashboardCoordinator?
    
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Entry>!
    private var entries: [Entry] = []
    private let entryManager: EntryManagerProtocol
    
    init(otherCoordinator: OtherCoordinator) {
        self.entryManager = otherCoordinator.entryManager
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.applyTheming()
        self.loadData()
        
    }
    
    // MARK: - Private Methods
    
    enum Section {
        case main
    }
    
    private func setupUI() {
        
        self.title = "Einträge validieren"
        
        // Setup collection view with list configuration
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(collectionView)
        
        // Setup data source
        configureDataSource()
        
    }
    
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.showsSeparators = true
        return UICollectionViewCompositionalLayout.list(using: config)
    }
    
    private func configureDataSource() {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Entry> { cell, indexPath, entry in
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    EntryValidationCellView(
                        image: nil,
                        title: entry.name ?? "",
                        description: entry.createdAt?.format(format: "dd.MM.yyyy HH:mm") ?? ""
                    )
                }
                .margins(.all, 0)
            } else {
                // Fallback for iOS 15
                var content = cell.defaultContentConfiguration()
                content.text = entry.name
                content.secondaryText = entry.createdAt?.format(format: "dd.MM.yyyy HH:mm")
                cell.contentConfiguration = content
            }
            cell.accessories = [.disclosureIndicator()]
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Entry>(collectionView: collectionView) {
            collectionView, indexPath, entry in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: entry)
        }
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Entry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(entries)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
    private func setupConstraints() {
        
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.safeTopAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func applyTheming() {
        self.view.backgroundColor = UIColor.systemBackground
        self.collectionView.backgroundColor = UIColor.systemBackground
    }
    
    private func loadData() {
        
        entryManager.get { (result) in
            
            switch result {
                
            case .success(let entries):
                
                self.entries = entries.filter { !$0.isValidated }
                self.updateSnapshot()
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
}
