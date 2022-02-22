//
//  SidebarViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import Combine
import SwiftUI
import AppScaffold
import Core

public class SidebarViewController: UIViewController {
    
    public let coordinators: [Coordinator]
    
    private var secondaryViewControllers: [UIViewController] = []
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem> = {
        return configureDataSource()
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: buildCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Initializers
    
    public init(coordinators: [Coordinator]) {
        
        self.coordinators = coordinators
        self.secondaryViewControllers = coordinators.map { $0.navigationController }
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.applyInitialSnapshot()
        self.setInitialSecondaryView()
        self.setupListeners()
        
    }
    
    // MARK: - Setup UI -
    
    private func setupUI() {
        
        self.navigationItem.title = CoreSettings.appName
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    private func setupListeners() {
        
        NotificationCenter.default.publisher(for: .updateFavorites)
            .sink { (_: Notification) in
                // Update favorites here
            }
            .store(in: &cancellables)
        
    }
    
    private func buildCollectionViewLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            config.headerMode = section == 0 ? .none : .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
        
    }
    
    private func configureDataSource() -> UICollectionViewDiffableDataSource<SidebarSection, SidebarItem> {
        
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure()]
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.image
            cell.accessibilityIdentifier = item.accessibilityIdentifier
            cell.accessibilityTraits = [.button]
            cell.contentConfiguration = content
            cell.accessories = []
        }
        
        return UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: SidebarItem) -> UICollectionViewCell? in
            if indexPath.item == 0 && indexPath.section != 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
    }
    
    private func applyInitialSnapshot() {
        
        let sections: [SidebarSection] = [.tabs, .places, .organisations]
        var snapshot = NSDiffableDataSourceSnapshot<SidebarSection, SidebarItem>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        for section in sections {
            switch section {
                case .tabs:
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
                    sectionSnapshot.append(SidebarItem.tabs)
                    dataSource.apply(sectionSnapshot, to: section)
                case .places:
                    let headerItem = SidebarItem(title: section.title)
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
                    sectionSnapshot.append([headerItem])
                    sectionSnapshot.append([], to: headerItem)
                    sectionSnapshot.expand([headerItem])
                    dataSource.apply(sectionSnapshot, to: section)
                case .organisations:
                    let headerItem = SidebarItem(title: section.title, image: nil)
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
                    sectionSnapshot.append([headerItem])
                    sectionSnapshot.append([], to: headerItem)
                    sectionSnapshot.expand([headerItem])
                    dataSource.apply(sectionSnapshot, to: section)
            }
        }
        
    }
    
    private func indexPath(of sidebarItem: SidebarItem) -> IndexPath? {
        if let index = SidebarItem.tabs.firstIndex(of: sidebarItem) {
            return IndexPath(item: Int(index), section: 0)
        }
        return nil
    }
    
    private func setInitialSecondaryView() {
        collectionView.selectItem(
            at: IndexPath(row: 0, section: 0),
            animated: false,
            scrollPosition: UICollectionView.ScrollPosition.centeredVertically
        )
        splitViewController?.setViewController(secondaryViewControllers[0], for: .secondary)
    }
    
    public func selectSidebarItem(_ item: SidebarItem) {
        
        guard let indexPath = indexPath(of: item) else { return }
        
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredVertically)
        splitViewController?.setViewController(secondaryViewControllers[0], for: .secondary)
    }
    
}

// MARK: - UICollectionViewDelegate -

extension SidebarViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            splitViewController?.preferredDisplayMode = .oneBesideSecondary
            splitViewController?.presentsWithGesture = false
            splitViewController?.preferredSplitBehavior = .tile
            splitViewController?.primaryBackgroundStyle = .sidebar
            splitViewController?.setViewController(secondaryViewControllers[indexPath.row], for: .secondary)
            
        }
        
        guard indexPath.section == 0 else { return }
        
    }
    
}
