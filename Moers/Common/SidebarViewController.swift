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

let tabsItems = [
    SidebarItem(
        title: AppStrings.Menu.dashboard,
        image: UIImage(systemName: "rectangle.grid.2x2"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.dashboard
    ),
    SidebarItem(
        title: AppStrings.Menu.news,
        image: UIImage(systemName: "newspaper"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.news
    ),
    SidebarItem(
        title: AppStrings.Menu.map,
        image: UIImage(systemName: "map"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.map
    ),
    SidebarItem(
        title: AppStrings.Menu.events,
        image: UIImage(systemName: "calendar"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.events
    ),
    SidebarItem(
        title: AppStrings.Menu.other,
        image: UIImage(systemName: "list.bullet"),
        accessibilityIdentifier: AccessibilityIdentifiers.Menu.other
    )
]

enum SidebarSection: String {
    case tabs
    case calendars = "Meine Kalender"
}

class SidebarViewController: UIViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>! = nil
    private var collectionView: UICollectionView! = nil
    private var secondaryViewControllers: [UIViewController] = []
    
    public let coordinators: [Coordinator]
    
    init(coordinators: [Coordinator]) {
        
        self.coordinators = coordinators
        self.secondaryViewControllers = coordinators.map { $0.navigationController }
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Mein Moers"
        navigationController?.navigationBar.prefersLargeTitles = true
        configureHierarchy()
        configureDataSource()
        setInitialSecondaryView()
    }
    
    private func setInitialSecondaryView() {
        collectionView.selectItem(
            at: IndexPath(row: 0, section: 0),
            animated: false,
            scrollPosition: UICollectionView.ScrollPosition.centeredVertically
        )
        splitViewController?.setViewController(secondaryViewControllers[0], for: .secondary)
    }
    
}

// MARK: - Layout

extension SidebarViewController {
    
    private func createLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            config.headerMode = section == 0 ? .none : .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
    }
    
}

// MARK: - Data

extension SidebarViewController {
    
    private func configureHierarchy() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func configureDataSource() {
        // Configuring cells
        
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
        
        // Creating the datasource
        
        dataSource = UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: SidebarItem) -> UICollectionViewCell? in
            if indexPath.item == 0 && indexPath.section != 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
        // Creating and applying snapshots
        
        let sections: [SidebarSection] = [.tabs/*, .calendars*/]
        var snapshot = NSDiffableDataSourceSnapshot<SidebarSection, SidebarItem>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        for section in sections {
            switch section {
                case .tabs:
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
                    sectionSnapshot.append(tabsItems)
                    dataSource.apply(sectionSnapshot, to: section)
                case .calendars:
                    let headerItem = SidebarItem(title: section.rawValue, image: nil, accessibilityIdentifier: nil)
                    var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
                    sectionSnapshot.append([headerItem])
                    sectionSnapshot.expand([headerItem])
                    dataSource.apply(sectionSnapshot, to: section)
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension SidebarViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
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
