//
//  EventsViewController.swift
//  
//
//  Created by Lennart Fischer on 15.04.21.
//


#if os(iOS)

import UIKit
import Fuse
import OSLog
import Combine
import MMPages

@available(iOS, deprecated: 26.0, message: "Use EventsViewController (iOS 26+) instead")
open class EventsViewController_Legacy: UIViewController, UISearchResultsUpdating {
    
    // MARK: - UI Elements
    
    public private(set) lazy var tableView = { ViewFactory.tableView(with: .grouped) }()
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
    
    // MARK: - Data
    
    public var events: [EventViewModel<Event>] = []
    private var currentDisplayMode = DisplayMode.overview(favouriteEvents: [], activeEvents: [], upcomingEvents: []) {
        didSet {
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
        
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .always
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
        
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
        
        self.view.addSubview(tableView)
        
        self.setupSearch()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.cellLayoutMarginsFollowReadableWidth = true
        self.tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        
        if #available(iOS 11.0, *) {
            self.tableView.contentInsetAdjustmentBehavior = .automatic
        }
        
        self.registerDefaultCells()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           tableView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           tableView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.tableView.backgroundColor = UIColor.systemBackground
        self.tableView.separatorColor = UIColor.separator
        self.searchController.searchBar.tintColor = EventPackageConfiguration.accentColor
        
    }
    
    private func setupSearch() {
        
        if self.isSearchEnabled {
            
            self.searchController.searchResultsUpdater = self
            self.searchController.obscuresBackgroundDuringPresentation = false
            self.searchController.searchBar.placeholder = String.localized("SearchEventsPrompt")
            self.searchController.hidesNavigationBarDuringPresentation = true
            
            self.definesPresentationContext = true
            
            if #available(iOS 11.0, *) {
                self.navigationItem.searchController = searchController
            } else {
                self.tableView.tableHeaderView = searchController.searchBar
            }
            
        }
        
    }
    
    private func registerDefaultCells() {
        
        self.tableView.register(EventTableViewCell.self)
        self.tableView.register(HintTableViewCell.self)
        self.tableView.register(EventHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: EventHeaderFooterView.identifier)
        
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
        
//        self.events = EventManager.shared.filterEvents(events) // TODO: ullllsddsf
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
        
//        let viewModel = EventDetailsViewModel(model: event)
//        let detailViewController = EventDetailViewController(viewModel: viewModel)
//
//        self.navigationController?.pushViewController(detailViewController, animated: true)
        
        self.onShowEvent?(event.model.id, event.model.pageID)
        
    }
    
    open func showFavourites() {
        
        let viewController = EventsViewController_Legacy()
        
        viewController.isSearchEnabled = false
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
        viewController.title = String.localized("Favourites")
        viewController.events = self.events
        viewController.currentDisplayMode = self.buildFavourites()
        
    }
    
    @discardableResult
    open func showNext() -> EventsViewController_Legacy {
        
        let viewController = EventsViewController_Legacy()
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
        
        if #available(iOS 12.0, *) {
            os_log(.info, "EventsViewController: %@", output)
        } else {
            print("EventsViewController: \(output)")
        }
        
    }
    
}

extension EventsViewController_Legacy: UITableViewDataSource, UITableViewDelegate {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        
        switch currentDisplayMode {
            case .overview(_, _, _):
                tableView.accessibilityIdentifier = "Events.Overview"
                return 3
                
            case .list(let keyedEvents):
                
                if keyedEvents.isEmpty {
                    return 1
                }
                
                return keyedEvents.count
                
            case .search(_, let filteredEvents):
                return filteredEvents.count
                
            case .favourites(let keyedEvents):
                return keyedEvents.count
                
            default:
                return 1
        }
        
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch currentDisplayMode {
            
            case .overview(let favouriteEvents, let activeEvents, let upcomingEvents):
                
                if section == 0 {
                    if favouriteEvents.isEmpty {
                        return 1
                    } else {
                        return favouriteEvents.count
                    }
                } else if section == 1 {
                    if activeEvents.isEmpty {
                        return 1
                    } else {
                        return activeEvents.count
                    }
                } else {
                    if upcomingEvents.isEmpty {
                        return 1
                    } else {
                        return upcomingEvents.count
                    }
                }
                
            case .list(let keyedEvents):
                
                if keyedEvents.isEmpty {
                    return 1
                }
                
                return keyedEvents[section].events.count
                
            case .search(_, let searchedEvents):
                return searchedEvents[section].events.count
                
            case .favourites(let keyedEvents):
                return keyedEvents[section].events.count
                
            default:
                return 0
        }
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch currentDisplayMode {
            
            case .overview(let favouriteEvents, let activeEvents, let upcomingEvents):
                
                if indexPath.section == 0 {
                    
                    if favouriteEvents.isEmpty {
                        return hintCell(with: String.localized("EventsNoFavourite"), at: indexPath)
                    } else {
                        return eventCell(for: favouriteEvents[indexPath.row], at: indexPath)
                    }
                    
                } else if indexPath.section == 1 {
                    
                    if activeEvents.isEmpty {
                        return hintCell(with: String.localized("EventsNoLive"), at: indexPath)
                    } else {
                        return eventCell(for: activeEvents[indexPath.row], at: indexPath)
                    }
                    
                } else {
                    
                    if upcomingEvents.isEmpty {
                        return hintCell(with: String.localized("EventsNoUpcoming"), at: indexPath)
                    } else {
                        return eventCell(for: upcomingEvents[indexPath.row], at: indexPath)
                    }
                    
                }
                
            case .list(let keyedEvents):
                
                if keyedEvents.isEmpty {
                    return hintCell(with: String.localized("EventsNoUpcoming"), at: indexPath)
                }
                
                let event = keyedEvents[indexPath.section].events[indexPath.row]
                
                return eventCell(for: event, at: indexPath)
                
            case .search(_, let searchedEvents):
                
                let event = searchedEvents[indexPath.section].events[indexPath.row]
                
                return eventCell(for: event, at: indexPath)
                
            case .favourites(let keyedEvents):
                
                let event = keyedEvents[indexPath.section].events[indexPath.row]
                
                return eventCell(for: event, at: indexPath)
                
            default:
                
                return UITableViewCell()
                
        }
        
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch currentDisplayMode {
            
            case .overview(let favouriteEvents, _, _):
                if section == 0 && favouriteEvents.isEmpty {
                    return 40
                } else {
                    return 40
                }
                
            default:
                return 40
        }
        
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: EventHeaderFooterView.identifier) as! EventHeaderFooterView
        
        switch currentDisplayMode {
            
            case .overview(_, _, _):
                
                if section == 0 {
                    
                    header.title = sectionFavouritesTitle
                    header.action = {
                        self.showFavourites()
                    }
                    
                } else if section == 1 {
                    
                    header.title = sectionActiveTitle
                    header.showMoreButton = false
                    
                } else {
                    
                    header.title = sectionUpcomingTitle
                    header.action = {
                        self.showNext()
                    }
                    
                }
                
            case .list(let keyedEvents):
                
                header.showMoreButton = false
                
                if !keyedEvents.isEmpty {
                    header.title = keyedEvents[section].header
                }
                
            case .search(_, let searchedEvents):
                
                header.showMoreButton = false
                header.title = searchedEvents[section].header
                
            case .favourites(let keyedEvents):
                
                header.showMoreButton = false
                header.title = keyedEvents[section].header
                
            default:
                break
        }
        
        return header
        
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cell = tableView.cellForRow(at: indexPath) as? EventTableViewCell else { return }
        
        guard let event = cell.event else { return }
        
        self.showEventDetailViewController(for: event)
        
    }
    
    public func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        
        if let _ = tableView.cellForRow(at: indexPath) as? EventTableViewCell {
            return true
        } else {
            return false
        }
        
    }
    
    // MARK: - Cells
    
    private func eventCell(for event: EventViewModel<Event>, at indexPath: IndexPath) -> EventTableViewCell {
        
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as EventTableViewCell
        
        cell.event = event
        
        return cell
        
    }
    
    private func hintCell(with text: String, at indexPath: IndexPath) -> HintTableViewCell {
        
        let cell = tableView.dequeueReusableCell(forIndexPath: indexPath) as HintTableViewCell
        
        cell.hint = text
        
        return cell
        
    }
    
}

#endif
