//
//  EventsViewController.swift
//  
//
//  Created by Lennart Fischer on 15.04.21.
//  Updated for iOS 26+ UICollectionView with list configuration on 27.12.24.
//


#if os(iOS)

import UIKit
import Fuse
import OSLog
import Combine
import MMPages

@available(iOS 26.0, *)
open class EventsViewController: UIViewController, UISearchResultsUpdating {
    
    // MARK: - Constants
    
    private static let indicatorViewTag = 999
    
    // MARK: - UI Elements
    
    public private(set) lazy var collectionView: UICollectionView = {
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    public private(set) lazy var searchController = { UISearchController(searchResultsController: nil) }()
    
    // MARK: - Config
    
    private let fuse = Fuse(threshold: 0.25, isCaseSensitive: false)
    
    private var updateInterval: TimeInterval = 60.0
    private var updateTimer: Timer!
    
    private var isSearchEnabled = true
    
    public var numberOfDisplayedUpcomingEvents = 12 { didSet { self.rebuildData() } }
    public var numberOfDisplayedUpcomingFavourites = 3 { didSet { self.rebuildData() } }
    public var sectionFavouritesTitle = String.localized("UpcomingFavourites").uppercased()
    public var sectionActiveTitle = String.localized("LiveNow").uppercased()
    public var sectionUpcomingTitle = String.localized("Upcoming").uppercased()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Data Source
    
    private enum Section: Hashable {
        case favourites
        case active
        case upcoming
        case dated(String)
    }
    
    private enum Item: Hashable {
        case event(EventViewModel<Event>)
        case hint(String)
    }
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    
    // MARK: - Data
    
    public var events: [EventViewModel<Event>] = []
    private var currentDisplayMode = DisplayMode.overview(favouriteEvents: [], activeEvents: [], upcomingEvents: []) {
        didSet {
            DispatchQueue.main.async {
                self.applySnapshot()
            }
        }
    }
    
    public var onShowEvent: ((Event.ID?, Page.ID?) -> Void)?
    
    // MARK: - UIViewController Lifecycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.configureDataSource()
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.setupInvalidators()
        self.loadData()
        self.updateUI()
        
        self.updateTimer = Timer.scheduledTimer(timeInterval: updateInterval,
                                                target: self,
                                                selector: #selector(updateUI),
                                                userInfo: nil,
                                                repeats: true)
        
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTimer?.invalidate()
        
    }
    
    public init(
        title: String = "",
        isSearchEnabled: Bool = true,
        events: [Event] = [],
        displayMode: DisplayMode = DisplayMode.overview(
            favouriteEvents: [],
            activeEvents: [],
            upcomingEvents: []
        )
    ) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.isSearchEnabled = isSearchEnabled
        self.events = events.map { EventViewModel(event: $0) }
        self.currentDisplayMode = displayMode
        self.rebuildData()
        
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.title = String.localized("EventsTitle")
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        updateTimer?.invalidate()
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.view.addSubview(collectionView)
        
        self.setupSearch()
        
        self.collectionView.delegate = self
        
    }
    
    private func setupConstraints() {
        
        let constraints = [collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
                           collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.collectionView.backgroundColor = UIColor.systemBackground
        self.searchController.searchBar.tintColor = EventPackageConfiguration.accentColor
        
    }
    
    private func setupSearch() {
        
        if self.isSearchEnabled {
            
            self.searchController.searchResultsUpdater = self
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchBar.placeholder = String.localized("SearchEventsPrompt")
            self.searchController.hidesNavigationBarDuringPresentation = true
            
            self.definesPresentationContext = true
            
            self.navigationItem.searchController = searchController
            
        }
        
    }
    
    // MARK: - Data Source Configuration
    
    private func configureDataSource() {
        
        // Cell registration for events
        let eventCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, EventViewModel<Event>> { cell, indexPath, event in
            var content = UIListContentConfiguration.cell()
            content.text = event.model.name
            content.secondaryText = event.subtitle
            content.textProperties.font = .boldSystemFont(ofSize: 18)
            content.secondaryTextProperties.font = .systemFont(ofSize: 16)
            content.secondaryTextProperties.color = .secondaryLabel
            
            // Add color indicator by adjusting content margins and using a custom background
            if let color = event.model.extras?.color {
                let indicatorColor: UIColor
                if color == "yellow" {
                    indicatorColor = EventColors.yellow
                } else if color == "green" {
                    indicatorColor = EventColors.green
                } else if color == "magenta" {
                    indicatorColor = EventColors.magenta
                } else if color == "blue" {
                    indicatorColor = EventColors.lightBlue
                } else {
                    indicatorColor = UIColor.gray
                }
                
                // Remove any existing indicator views to avoid duplicates
                cell.contentView.subviews.forEach { subview in
                    if subview.tag == Self.indicatorViewTag {
                        subview.removeFromSuperview()
                    }
                }
                
                // Create a custom view for the leading indicator
                let indicatorView = UIView()
                indicatorView.backgroundColor = indicatorColor
                indicatorView.translatesAutoresizingMaskIntoConstraints = false
                indicatorView.tag = Self.indicatorViewTag
                
                cell.contentView.addSubview(indicatorView)
                
                NSLayoutConstraint.activate([
                    indicatorView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    indicatorView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 8),
                    indicatorView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -8),
                    indicatorView.widthAnchor.constraint(equalToConstant: 2)
                ])
                
                // Adjust content insets to make room for indicator
                content.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 32, bottom: 8, trailing: 16)
            }
            
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            cell.backgroundConfiguration = backgroundConfig
            
            // Add heart icon for liked events
            if event.isLiked {
                let heartImage = Images.heartFill.withRenderingMode(.alwaysTemplate)
                var accessories: [UICellAccessory] = []
                accessories.append(.customView(configuration: .init(customView: {
                    let imageView = UIImageView(image: heartImage)
                    imageView.tintColor = EventPackageConfiguration.accentColor
                    imageView.contentMode = .scaleAspectFit
                    imageView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        imageView.widthAnchor.constraint(equalToConstant: 10),
                        imageView.heightAnchor.constraint(equalToConstant: 10)
                    ])
                    return imageView
                }(), placement: .trailing(displayed: .always))))
                cell.accessories = accessories
            } else {
                cell.accessories = []
            }
        }
        
        // Cell registration for hints
        let hintCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, indexPath, hint in
            var content = UIListContentConfiguration.cell()
            content.text = hint
            content.textProperties.color = .secondaryLabel
            content.textProperties.alignment = .center
            cell.contentConfiguration = content
            
            var backgroundConfig = UIBackgroundConfiguration.listGroupedCell()
            cell.backgroundConfiguration = backgroundConfig
        }
        
        // Create data source
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, item in
            switch item {
            case .event(let event):
                return collectionView.dequeueConfiguredReusableCell(using: eventCellRegistration, for: indexPath, item: event)
            case .hint(let hint):
                return collectionView.dequeueConfiguredReusableCell(using: hintCellRegistration, for: indexPath, item: hint)
            }
        }
        
        // Header registration
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            guard let self = self else { return }
            
            var content = UIListContentConfiguration.groupedHeader()
            
            let snapshot = self.dataSource.snapshot()
            let section = snapshot.sectionIdentifiers[indexPath.section]
            
            switch section {
            case .favourites:
                content.text = self.sectionFavouritesTitle
            case .active:
                content.text = self.sectionActiveTitle
            case .upcoming:
                content.text = self.sectionUpcomingTitle
            case .dated(let dateString):
                content.text = dateString
            }
            
            headerView.contentConfiguration = content
        }
        
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        
        switch currentDisplayMode {
        case .overview(let favouriteEvents, let activeEvents, let upcomingEvents):
            
            snapshot.appendSections([.favourites])
            if favouriteEvents.isEmpty {
                snapshot.appendItems([.hint(String.localized("EventsNoFavourite"))], toSection: .favourites)
            } else {
                snapshot.appendItems(favouriteEvents.map { .event($0) }, toSection: .favourites)
            }
            
            snapshot.appendSections([.active])
            if activeEvents.isEmpty {
                snapshot.appendItems([.hint(String.localized("EventsNoLive"))], toSection: .active)
            } else {
                snapshot.appendItems(activeEvents.map { .event($0) }, toSection: .active)
            }
            
            snapshot.appendSections([.upcoming])
            if upcomingEvents.isEmpty {
                snapshot.appendItems([.hint(String.localized("EventsNoUpcoming"))], toSection: .upcoming)
            } else {
                snapshot.appendItems(upcomingEvents.map { .event($0) }, toSection: .upcoming)
            }
            
        case .list(let keyedEvents):
            if keyedEvents.isEmpty {
                snapshot.appendSections([.dated("")])
                snapshot.appendItems([.hint(String.localized("EventsNoUpcoming"))], toSection: .dated(""))
            } else {
                for (header, events) in keyedEvents {
                    let section = Section.dated(header)
                    snapshot.appendSections([section])
                    snapshot.appendItems(events.map { .event($0) }, toSection: section)
                }
            }
            
        case .search(_, let searchedEvents):
            for (header, events) in searchedEvents {
                let section = Section.dated(header)
                snapshot.appendSections([section])
                snapshot.appendItems(events.map { .event($0) }, toSection: section)
            }
            
        case .favourites(let keyedEvents):
            for (header, events) in keyedEvents {
                let section = Section.dated(header)
                snapshot.appendSections([section])
                snapshot.appendItems(events.map { .event($0) }, toSection: section)
            }
            
        default:
            break
        }
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    public func rebuildData() {
        
        DispatchQueue.main.async {
            switch self.currentDisplayMode {
                
                case .overview(_, _, _):
                    self.currentDisplayMode = self.buildOverview()
                    
                case .list(_):
                    self.currentDisplayMode = self.buildList()
                    
                case .search(_, _):
                    self.currentDisplayMode = self.buildSearch()
                    
                case .favourites(_):
                    self.currentDisplayMode = self.buildFavourites()
                    
                default:
                    break
            }
        }
        
    }
    
    open func loadData() {
        
        
        
    }
    
    open func filterActive(events: [EventViewModel<Event>]) -> [EventViewModel<Event>] {
        return events.filter { $0.isActive }
    }
    
    open func filterUpcoming(events: [EventViewModel<Event>]) -> [EventViewModel<Event>] {
        return events.filter { !$0.isActive }
    }
    
    @objc private func updateUI() {
        
        self.logStatement("Updating UI.")
        
        self.rebuildData()
        
        self.logStatement("Updated UI.")
        
    }
    
    // MARK: - Factoring Data
    
    public func buildOverview() -> DisplayMode {
        
        let favourites: [EventViewModel<Event>] = events.filter {
            $0.isLiked && ($0.model.startDate ?? Date(timeIntervalSinceNow: 60)) > Date()
        }
        let active: [EventViewModel<Event>] = filterActive(events: events)
        let upcoming: [EventViewModel<Event>] = filterUpcoming(events: events)
        
        var upcomingCount = upcoming.count
        var favouritesCount = favourites.count
        
        if upcomingCount > numberOfDisplayedUpcomingEvents {
            upcomingCount = numberOfDisplayedUpcomingEvents
        }
        if favouritesCount > numberOfDisplayedUpcomingFavourites {
            favouritesCount = numberOfDisplayedUpcomingFavourites
        }
        
        let upcomingReduced: [EventViewModel<Event>] = Array(upcoming.prefix(through: upcomingCount - 1))
        let favouritesReduced: [EventViewModel<Event>] = Array(favourites.prefix(through: favouritesCount - 1))
        
        return DisplayMode.overview(favouriteEvents: favouritesReduced, activeEvents: active, upcomingEvents: upcomingReduced)
        
    }
    
    public func buildList() -> DisplayMode {
        
        let keyedEvents = self.eventsToKeyed(events)
        
        return DisplayMode.list(keyedEvents: keyedEvents)
        
    }
    
    public func buildSearch() -> DisplayMode {
        
        let searchTerm = searchController.searchBar.text ?? ""
        
        var filteredEvents: [EventViewModel<Event>] = []
        
        if isFiltering() {
            
            let names = events.map { $0.model }.map { $0.name }
            let results = fuse.search(searchTerm, in: names)
            
            filteredEvents = results.compactMap { (index, score, matchedRanges) in
                
                let event = events[index]
                
                return event
                
            }
            
        } else {
            
            filteredEvents = events
            
        }
        
        let keyedEvents = eventsToKeyed(filteredEvents)
        
        return DisplayMode.search(searchTerm: searchTerm, searchedEvents: keyedEvents)
        
    }
    
    public func buildFavourites() -> DisplayMode {
        
        let favouriteEvents = events.filter { $0.isLiked }
        
        let keyedEvents = eventsToKeyed(favouriteEvents)
        
        return DisplayMode.favourites(keyedEvents: keyedEvents)
        
    }
    
    private func eventsToKeyed(_ events: [EventViewModel<Event>]) -> [(String, [EventViewModel<Event>])] {
        
        var keyedEvents: [String: [EventViewModel<Event>]] = [:]
        
        for viewModel in events {
            
            let key = viewModel.model.startDate?.format(format: "EEEE, dd.MM.yyyy") ?? "nicht bekannt"
            
            var kEvent = keyedEvents[key] ?? []
            
            kEvent.append(viewModel)
            
            keyedEvents[key] = kEvent
            
        }
        
        let sorted = keyedEvents.sorted { (a, b) -> Bool in
            return Date.from(a.key, withFormat: "EEEE, dd.MM.yyyy") ?? Date(timeIntervalSinceNow: pow(86400, 4)) < Date.from(b.key, withFormat: "EEEE, dd.MM.yyyy") ?? Date(timeIntervalSinceNow: pow(86400, 4))
        }
        
        return sorted
        
    }
    
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    private func setupInvalidators() {
        
        let observer1 = NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
        let observer2 = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
        let observer3 = NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
        
        observer1.sink { _ in
            self.updateTimer?.invalidate()
        }.store(in: &cancellables)
        
        observer2.sink { _ in
            self.updateTimer?.invalidate()
        }.store(in: &cancellables)
        
        observer3.sink { _ in
            self.updateTimer?.invalidate()
        }.store(in: &cancellables)
        
    }
    
    // MARK: - Public Callbacks
    
    open func showEventDetailViewController(for event: EventViewModel<Event>) {
        
        self.onShowEvent?(event.model.id, event.model.pageID)
        
    }
    
    open func showFavourites() {
        
        let viewController = EventsViewController()
        
        viewController.isSearchEnabled = false
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
        viewController.title = String.localized("Favourites")
        viewController.events = self.events
        viewController.currentDisplayMode = self.buildFavourites()
        
    }
    
    @discardableResult
    open func showNext() -> EventsViewController {
        
        let viewController = EventsViewController()
        viewController.title = String.localized("EventsTitle")
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
        viewController.events = self.events
        viewController.currentDisplayMode = self.buildList()
        
        return viewController
        
    }
    
    // MARK: - Search
    
    public func updateSearchResults(for searchController: UISearchController) {
        
        if searchController.isActive {
            self.currentDisplayMode = buildSearch()
        } else {
            self.currentDisplayMode = buildOverview()
        }
        
    }
    
    // MARK: - Utility
    
    private func logStatement(_ output: String) {
        
        os_log(.info, "EventsViewController: %@", output)
        
    }
    
}

@available(iOS 26.0, *)
extension EventsViewController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .event(let event):
            self.showEventDetailViewController(for: event)
        case .hint:
            break
        }
    }
    
}

// MARK: - Legacy Support Wrapper

#if compiler(>=6.0)
/// Factory method to create the appropriate events view controller based on iOS version
public func createEventsViewController(
    title: String = "",
    isSearchEnabled: Bool = true,
    events: [Event] = [],
    displayMode: DisplayMode = DisplayMode.overview(
        favouriteEvents: [],
        activeEvents: [],
        upcomingEvents: []
    )
) -> UIViewController {
    if #available(iOS 26.0, *) {
        return EventsViewController(title: title, isSearchEnabled: isSearchEnabled, events: events, displayMode: displayMode)
    } else {
        return EventsViewController_Legacy(title: title, isSearchEnabled: isSearchEnabled, events: events, displayMode: displayMode)
    }
}
#endif

#endif
