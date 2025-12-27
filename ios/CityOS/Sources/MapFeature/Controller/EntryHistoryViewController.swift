//
//  EntryHistoryViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 31.12.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import SwiftUI


class EntryHistoryViewController: UIViewController {

    public var coordinator: MapCoordintor?
    
    public var entry: Entry?
    
    private let entryManager: EntryManagerProtocol
    private var audits: [Audit] = []
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Audit>!
    
    init(coordinator: MapCoordintor) {
        self.coordinator = coordinator
        self.entryManager = coordinator.entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    init(entryManager: EntryManagerProtocol) {
        self.entryManager = entryManager
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
        self.setupTheming()
        
        self.loadHistory()
        
    }
    
    // MARK: - Private Methods
    
    enum Section {
        case main
    }
    
    private func setupUI() {
        
        self.title = "Historie"
        
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
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Audit> { cell, indexPath, audit in
            if #available(iOS 16.0, *) {
                cell.contentConfiguration = UIHostingConfiguration {
                    AuditCellView(audit: audit)
                }
                .margins(.all, 0)
            } else {
                // Fallback for iOS 15
                var content = cell.defaultContentConfiguration()
                content.text = self.auditEventText(for: audit.event)
                content.secondaryText = "vor " + (audit.updatedAt?.timeAgo() ?? "n/v")
                cell.contentConfiguration = content
            }
            cell.accessories = []
        }
        
        dataSource = UICollectionViewDiffableDataSource<Section, Audit>(collectionView: collectionView) {
            collectionView, indexPath, audit in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: audit)
        }
    }
    
    private func auditEventText(for event: Audit.EventType) -> String {
        switch event {
        case .created:
            return "Eintrag erstellt"
        case .updated:
            return "Eintrag aktualisiert"
        case .deleted:
            return "Eintrag gelöscht"
        case .restored:
            return "Eintrag widerhergestellt"
        }
    }
    
    private func setupConstraints() {
        
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.safeTopAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.safeLeftAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.safeRightAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
    }

    private func loadHistory() {
        
        guard let entry = entry else { return }
        
        entryManager.fetchHistory(entry: entry) { (result) in
            
            switch result {
                
            case .success(let audits):
                
                DispatchQueue.main.async {
                    self.audits = audits.sorted(by: { (lhs, rhs) -> Bool in
                        return lhs.updatedAt ?? Date() > rhs.updatedAt ?? Date()
                    })
                    self.updateSnapshot()
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                
            }
            
        }
        
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Audit>()
        snapshot.appendSections([.main])
        snapshot.appendItems(audits)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
    
}
