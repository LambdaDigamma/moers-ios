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

final class FilterBox: ObservableObject {
    @Published var filter: EventFilter
    init(filter: EventFilter) {
        self.filter = filter
    }
}

class UserScheduleViewController: UIViewController, UICollectionViewDelegate {

    @LazyInjected(\.favoriteEventsStore) var favoriteEventsStore
    
    @PersistedFilter(key: "favoritesFilter") var filter: EventFilter {
        didSet {
            self.reload()
        }
    }
    
    var dataSource: UICollectionViewDiffableDataSource<UserScheduleSection, UserScheduleItem>?
    var cancellables = Set<AnyCancellable>()
    private var favoritesCancellable: AnyCancellable?
    private var filterCancellable: AnyCancellable?
    
    let dateComponentsFormatter = DateComponentsFormatter()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [filterBar, collectionView])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var filterBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        
        let icon = UIImageView(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"))
        icon.tintColor = AppColors.navigationAccent
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        
        let label = UILabel()
        label.text = EventPackageStrings.filterActive
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let button = UIButton(type: .system)
        button.setTitle(EventPackageStrings.clearFilter, for: .normal)
        button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline).bold()
        button.addTarget(self, action: #selector(clearFilter), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        let stack = UIStackView(arrangedSubviews: [icon, label, UIView(), button])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            
            icon.widthAnchor.constraint(equalToConstant: 20),
            icon.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        return view
    }()
    
    // MARK: - UIViewController Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = [.bottom]
        self.extendedLayoutIncludesOpaqueBars = true
        
        self.setupUI()
        self.setupConstraints()
        self.setupCollectionViewDataSource()
        self.setupLoadListeners()
        
    }
    
    func setupUI() {
        
        self.view.addSubview(mainStackView)
        self.collectionView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: filter.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(showFilter)
        )
        
        self.updateFilterBar()
        
    }
    
    func setupConstraints() {
        
        let constraints = [
            mainStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc func clearFilter() {
        self.filter = .empty
    }
    
    @objc func showFilter() {
        
        let box = FilterBox(filter: self.filter)
        
        filterCancellable = box.$filter
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newFilter in
                // We update our local filter when the box changes.
                // This triggers the PersistedFilter setter.
                self?.filter = newFilter
            }
        
        let filterView = EventFilterSheetWrapper(box: box, isFavoritesFilterEnabled: false)
        
        let hostingController = UIHostingController(rootView: filterView)
        self.present(hostingController, animated: true)
        
    }
    
    func reload() {
        
        self.navigationItem.rightBarButtonItem?.image = UIImage(systemName: filter.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
        
        self.updateFilterBar()
        self.setupLoadListeners()
        
    }
    
    private func updateFilterBar() {
        self.filterBar.isHidden = filter.isEmpty
    }
    
    func setupLoadListeners() {
        
        favoritesCancellable?.cancel()
        
        favoritesCancellable = favoriteEventsStore?.observeFavoriteEvents()
            .sink(receiveCompletion: { (completion: Subscribers.Completion<any Error>) in
                
            }, receiveValue: { (events: [FavoriteEventInfo]) in
                
                let filteredEvents = events.filter { info in
                    if self.filter.venueIDs.isEmpty {
                        return true
                    }
                    guard let placeID = info.place?.id else {
                        return false
                    }
                    return self.filter.venueIDs.contains(Int(placeID))
                }
                
                if filteredEvents.isEmpty {
                    
                    var snapshot = NSDiffableDataSourceSnapshot<UserScheduleSection, UserScheduleItem>()
                    snapshot.appendSections([.empty])
                    snapshot.appendItems([.placeholder])
                    self.dataSource?.apply(snapshot)
                    
                } else {
                
                    let groupedDictionary = OrderedDictionary(grouping: filteredEvents) { element in
                        element.event.startDate.getDateForGroup(acceptedOffset: 3 * 60 * 60)
                    }
                        .mapValues {
                            $0.map {
                                UserScheduleItem.event(EventListItemViewModel(
                                    eventID: $0.event.toBase().id,
                                    title: $0.event.toBase().name,
                                    startDate: $0.event.toBase().startDate,
                                    endDate: $0.event.toBase().endDate,
                                    location: $0.place?.name,
                                    media: nil,
                                    isOpenEnd: $0.event.toBase().extras?.openEnd ?? false,
                                    isLiked: true,
                                    scheduleDisplayMode: $0.event.toBase().scheduleDisplayMode
                                ))
                            }
                        }
                    
                    var snapshot = NSDiffableDataSourceSnapshot<UserScheduleSection, UserScheduleItem>()
                    
                    for (key, value) in groupedDictionary {
                        
                        snapshot.appendSections([.main(key)])
                        snapshot.appendItems(value)
                        
                    }
                    
                    self.dataSource?.apply(snapshot)
                    
                }
                
            })
        
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
        
        let eventCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, EventListItemViewModel> { cell, indexPath, item in
            cell.contentConfiguration = UIHostingConfiguration {
                
                EventListItem(viewModel: item)
                    .showFavoriteIcon(false)
                
            }
            cell.backgroundConfiguration = .listPlainCell()
            
        }
        
        let placeholderCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, hint in
            var content = UIListContentConfiguration.cell()
            content.text = hint
            content.textProperties.color = .secondaryLabel
            content.textProperties.alignment = .center
            content.image = UIImage(systemName: "heart.slash")
            content.imageProperties.tintColor = .secondaryLabel
            content.imageToTextPadding = 12
            cell.contentConfiguration = content
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
                case .empty:
                    break
                
            }
            
            // Apply the configuration to header view
            headerView.contentConfiguration = configuration
            
        }
        
        /// Create a datasource and connect it to  collection view `collectionView`
        dataSource = UICollectionViewDiffableDataSource<UserScheduleSection, UserScheduleItem>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: UserScheduleItem) -> UICollectionViewCell? in
            
            switch item {
            case .event(let eventViewModel):
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: eventCellRegistration,
                    for: indexPath,
                    item: eventViewModel
                )
                return cell
            case .placeholder:
                let message = self.filter.isEmpty ? String(localized: "No event has been marked as a favorite yet.") : EventPackageStrings.noFavoriteEventsForFilter
                let cell = collectionView.dequeueConfiguredReusableCell(
                    using: placeholderCellRegistration,
                    for: indexPath,
                    item: message
                )
                return cell
            }
            
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
        
        guard case .event(let eventViewModel) = item else { return }
        
        guard let eventID = eventViewModel.eventID else { return }
        
        let detailController = ModernEventDetailViewController(
            eventID: eventID
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
