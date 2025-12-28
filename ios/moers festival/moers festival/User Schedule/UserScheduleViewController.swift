//
//  UserScheduleViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import UIKit
import SwiftUI
import Factory
import MMEvents
import Combine
import OrderedCollections

class UserScheduleViewController: UIViewController, UICollectionViewDelegate {

    @LazyInjected(\.favoriteEventsStore) var favoriteEventsStore
    
    var dataSource: UICollectionViewDiffableDataSource<UserScheduleSection, EventListItemViewModel>?
    var cancellables = Set<AnyCancellable>()
    
    let dateComponentsFormatter = DateComponentsFormatter()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - UIViewController Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupCollectionViewDataSource()
        self.setupLoadListeners()
        
    }
    
    func setupUI() {
        
        self.view.addSubview(collectionView)
        self.collectionView.delegate = self
        
    }
    
    func setupConstraints() {
        
        let constraints = [
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    func setupLoadListeners() {
        
        favoriteEventsStore?.observeFavoriteEvents()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<any Error>) in
                
            }, receiveValue: { (events: [FavoriteEventInfo]) in
                
                let groupedDictionary = OrderedDictionary(grouping: events) { element in
                    element.event.startDate.getDateForGroup(acceptedOffset: 3 * 60 * 60)
                }
                    .mapValues {
                        $0.map {
                            EventListItemViewModel(
                                eventID: $0.event.toBase().id,
                                title: $0.event.toBase().name,
                                startDate: $0.event.toBase().startDate,
                                endDate: $0.event.toBase().endDate,
                                location: $0.place?.name,
                                media: nil,
                                isOpenEnd: $0.event.toBase().extras?.openEnd ?? false,
                                isLiked: true,
                                isPreview: $0.event.toBase().isPreview
                            )
                        }
                    }
                
                var snapshot = NSDiffableDataSourceSnapshot<UserScheduleSection, EventListItemViewModel>()
                
                for (key, value) in groupedDictionary {
                    
                    snapshot.appendSections([.main(key)])
                    snapshot.appendItems(value)
                    
                }
                
                self.dataSource?.apply(snapshot)
                
            })
            .store(in: &cancellables)
        
    }
    
    // MARK: - List -
    
    func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, environment -> NSCollectionLayoutSection? in
            
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .supplementary
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            
            let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            headerElement.pinToVisibleBounds = true
            headerElement.extendsBoundary = true
            headerElement.zIndex = 100000
            
            let section = NSCollectionLayoutSection.list(
                using: configuration,
                layoutEnvironment: environment
            )
            section.boundarySupplementaryItems = [headerElement]
            
            let separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .plain)
            
            configuration.separatorConfiguration = separatorConfiguration
            
            return section
            
        }
        return layout
    }
    
    func setupCollectionViewDataSource() {
        
        dateComponentsFormatter.allowedUnits = [.day, .month, .year]
        dateComponentsFormatter.unitsStyle = .full
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, EventListItemViewModel> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                
                EventListItem(viewModel: item)
                    .showFavoriteIcon(false)
                
            }
            cell.backgroundConfiguration = .listPlainCell()
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [unowned self] (headerView, elementKind, indexPath) in
            
            // Obtain header item using index path
            let headerItem = self.dataSource!.snapshot().sectionIdentifiers[indexPath.section]
            
            // Configure header view content based on headerItem
            var configuration = headerView.defaultContentConfiguration()
            
            switch headerItem {
                case .main(let dateComponents):
                    if let dateComponents {
                        configuration.text = self.format(dateComponents: dateComponents)
                    } else {
                        configuration.text = EventPackageStrings.notYetScheduled
                    }
                
            }
            
            // Apply the configuration to header view
            headerView.contentConfiguration = configuration
            
        }
        
        /// Create a datasource and connect it to  collection view `collectionView`
        dataSource = UICollectionViewDiffableDataSource<UserScheduleSection, EventListItemViewModel>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: EventListItemViewModel) -> UICollectionViewCell? in
            
            let cell = collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
            
            return cell
        }
        
        dataSource!.supplementaryViewProvider = { [unowned self]
            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                
                // Dequeue header view
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration, 
                    for: indexPath
                )
                
            }
            
            return nil
            
        }
        
    }
    
    // MARK: - UICollectionViewDelegate -
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let item = dataSource?.itemIdentifier(for: indexPath)
        
        guard let eventID = item?.eventID else { return }
        
        let detailController = ModernEventDetailViewController(
            eventID: eventID,
            eventService: nil
        )
        
        self.navigationController?.pushViewController(detailController, animated: true)
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
    // MARK: - Helpers -
    
    private func format(dateComponents: DateComponents) -> String {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        
        dateFormatter.locale = Locale.autoupdatingCurrent
        
        // Format the date components into a localized string
        if let date = Calendar.autoupdatingCurrent.date(from: dateComponents) {
            return date.formatted(.dateTime.day().month().year().weekday(.wide))
        } else {
            return ""
        }
        
    }
    
}
