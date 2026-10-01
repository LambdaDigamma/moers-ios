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
    private var dataSource: UICollectionViewDiffableDataSource<Section, Int>!
    private var entries: [Entry] = []
    private var entriesByID: [Int: Entry] = [:]
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
        
        Task {
            await self.loadData()
        }
        
    }
    
    // MARK: - Private Methods
    
    nonisolated enum Section: Hashable, Sendable {
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Int> { [weak self] cell, indexPath, entryID in
            guard let entry = self?.entriesByID[entryID] else {
                cell.contentConfiguration = UIListContentConfiguration.cell()
                cell.accessories = []
                return
            }

            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    EntryValidationCellView(
                        image: nil,
                        title: entry.name,
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
        
        dataSource = UICollectionViewDiffableDataSource<Section, Int>(collectionView: collectionView) {
            collectionView, indexPath, entryID in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: entryID)
        }
    }
    
    private func updateSnapshot() {
        entriesByID = Dictionary(uniqueKeysWithValues: entries.map { ($0.id, $0) })

        var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
        snapshot.appendSections([.main])
        snapshot.appendItems(entries.map(\.id))
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
    
    private func loadData() async {
        
        do {
            let entries = try await entryManager.get()
            self.entries = entries.filter { !$0.isValidated }
        } catch {
            print(error.localizedDescription)
        }
        
        self.entries = entries.filter { !$0.isValidated }
                
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
