//
//  EventsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.06.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Core
import Events
import OSLog
import UIKit
import SwiftUI

@MainActor
final class EventsViewController: UIViewController, TabBarItemProvider, CoordinatorAssignable {

    public var coordinator: EventCoordinator?

    private typealias DataSource = UICollectionViewDiffableDataSource<EventSection, EventItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<EventSection, EventItem>

    private let logger = Logger(.coreUi)
    private let searchController = UISearchController(searchResultsController: nil)
    private let injectedEventService: (any EventService)?
    private let calendar: Calendar
    private let now: () -> Date
    private var referenceDate: Date
    private var pendingSelectedEvent: Event?
    private var isDismissingSearch = false

    init(eventService: (any EventService)? = nil, calendar: Calendar = .autoupdatingCurrent, now: @escaping () -> Date = Date.init) {
        self.injectedEventService = eventService
        self.calendar = calendar
        self.now = now
        self.referenceDate = now()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var loadTask: Task<Void, Never>?
    private var searchUpdateTask: Task<Void, Never>?

    private var allEvents: [Event] = []
    private var searchIndex: [Event.ID: String] = [:]
    private var filter = EventFilter()
    private var searchText = ""
    private var isLoading = true
    private var errorMessage: String?
    private var sectionCounts: [EventSection: Int] = [:]
    private var suppressCollectionSelectionsUntil: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureSearch()
        configureCollectionView()
        configureDataSource()
        NotificationCenter.default.addObserver(self, selector: #selector(calendarDayChanged), name: .NSCalendarDayChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sceneDidActivate(_:)), name: UIScene.didActivateNotification, object: nil)
        applySnapshot(animated: false)
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if #available(iOS 26.0, *) {
            self.collectionView.rightEdgeEffect.style = .soft
        }
        
        UserActivity.current = UserActivities.configureEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }

        if !calendar.isDate(referenceDate, inSameDayAs: now()) {
            loadData()
        } else {
            applySnapshot(animated: false)
        }
    }

    nonisolated deinit {
        loadTask?.cancel()
        searchUpdateTask?.cancel()
    }

    private func configureView() {
        title = AppStrings.Menu.events
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain,
            target: self,
            action: #selector(showFilters)
        )
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    private func configureSearch() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = String(localized: "Search Events")
        searchController.searchBar.searchTextField.clearButtonMode = .whileEditing

        navigationItem.searchController = searchController
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.accessibilityIdentifier = "events.list"
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshEvents), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            EventLoadingCell.self,
            forCellWithReuseIdentifier: EventLoadingCell.reuseIdentifier
        )
        collectionView.register(
            EventQuickFilterCell.self,
            forCellWithReuseIdentifier: EventQuickFilterCell.reuseIdentifier
        )
        collectionView.register(
            EventSpotlightCell.self,
            forCellWithReuseIdentifier: EventSpotlightCell.reuseIdentifier
        )
        collectionView.register(
            EventListCell.self,
            forCellWithReuseIdentifier: EventListCell.reuseIdentifier
        )
        collectionView.register(
            EventEmptyCell.self,
            forCellWithReuseIdentifier: EventEmptyCell.reuseIdentifier
        )
        collectionView.register(
            EventSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EventSectionHeaderView.reuseIdentifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            guard let self else { return UICollectionViewCell() }

            switch item {
            case .loading:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EventLoadingCell.reuseIdentifier,
                    for: indexPath
                ) as! EventLoadingCell
                cell.startAnimating()
                return cell
            case .quickFilter(let quickFilter):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EventQuickFilterCell.reuseIdentifier,
                    for: indexPath
                ) as! EventQuickFilterCell
                cell.configure(with: quickFilter, isSelected: quickFilter.isSelected(in: filter))
                return cell
            case .spotlight(let event):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EventSpotlightCell.reuseIdentifier,
                    for: indexPath
                ) as! EventSpotlightCell
                cell.configure(with: event)
                return cell
            case .event(let event):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EventListCell.reuseIdentifier,
                    for: indexPath
                ) as! EventListCell
                cell.configure(with: event, emphasized: isEmphasized(event))
                return cell
            case .empty(let title, let message):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EventEmptyCell.reuseIdentifier,
                    for: indexPath
                ) as! EventEmptyCell
                cell.configure(title: title, message: message, onRetry: errorMessage == nil ? nil : { [weak self] in
                    self?.loadData()
                })
                return cell
            }
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader,
                  let self,
                  let section = self.section(at: indexPath.section),
                  let title = section.title else {
                return nil
            }

            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: EventSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! EventSectionHeaderView
            headerView.configure(title: title, count: self.sectionCounts[section, default: 0])

            return headerView
        }
    }

    private func loadData() {
        guard let eventService = injectedEventService ?? coordinator?.eventService else {
            isLoading = false
            applySnapshot(animated: false)
            return
        }

        loadTask?.cancel()
        isLoading = true
        errorMessage = nil
        applySnapshot(animated: true)

        loadTask = Task { [weak self, logger] in
            do {
                let response = try await eventService.index(cacheMode: .revalidate, withPages: false) { [weak self] events in
                    guard !Task.isCancelled else { return }
                    self?.handleLoadingProgress(events)
                }
                let events = response.data

                guard !Task.isCancelled else { return }

                self?.handleLoadedEvents(events)
            } catch {
                guard !Task.isCancelled else { return }

                logger.error("Events could not be fully loaded")
                self?.handleLoadingError(error)
            }
        }
    }

    private func updateEvents(_ events: [Event]) {
        allEvents = sorted(Event.unique(events))
        searchIndex = Dictionary(allEvents.map { ($0.id, EventFormatter.searchableText(for: $0)) }, uniquingKeysWith: { first, _ in first })
    }

    private func handleLoadingProgress(_ events: [Event]) {
        updateEvents(events + allEvents)
        applySnapshot(animated: false)
    }

    private func handleLoadedEvents(_ events: [Event]) {
        updateEvents(events)
        isLoading = false
        collectionView.refreshControl?.endRefreshing()
        errorMessage = nil
        applySnapshot(animated: true)
    }

    private func handleLoadingError(_ error: Error) {
        isLoading = false
        collectionView.refreshControl?.endRefreshing()
        if let partialError = error as? EventIndexLoadError {
            updateEvents(partialError.events + allEvents)
            errorMessage = String(localized: "Some events could not be loaded. Try again.")
        } else {
            errorMessage = String(localized: "Check your connection and try again.")
        }
        applySnapshot(animated: true)
    }

    private func applySnapshot(animated: Bool) {
        referenceDate = now()
        sectionCounts = [:]

        var snapshot = Snapshot()

        if isLoading && allEvents.isEmpty {
            snapshot.appendSections([.loading])
            snapshot.appendItems([.loading], toSection: .loading)
            apply(snapshot, animated: animated)
            return
        }

        snapshot.appendSections([.quickFilters])
        let options = EventFilterOptions(events: allEvents)
        let quickFilters = EventQuickFilter.allCases.filter { $0 != .free || options.supportsFreeFilter }
        snapshot.appendItems(quickFilters.map { .quickFilter($0) }, toSection: .quickFilters)

        let events = visibleEvents()

        if events.isEmpty {
            if isLoading {
                snapshot.appendSections([.loading])
                snapshot.appendItems([.loading], toSection: .loading)
            } else {
                snapshot.appendSections([.empty])
                snapshot.appendItems([emptyItem()], toSection: .empty)
            }
            apply(snapshot, animated: animated)
            updateFilterButton()
            return
        }

        if errorMessage != nil {
            snapshot.appendSections([.empty])
            snapshot.appendItems([emptyItem()], toSection: .empty)
        }

        let spotlights = spotlightEvents(from: events)
        if !spotlights.isEmpty {
            append(spotlights, as: .spotlights, item: EventItem.spotlight, to: &snapshot)
        }

        append(todayEvents(from: events), as: .today, item: EventItem.event, to: &snapshot)
        append(tomorrowEvents(from: events), as: .tomorrow, item: EventItem.event, to: &snapshot)
        append(nextDaysEvents(from: events), as: .nextDays, item: EventItem.event, to: &snapshot)
        append(futureEvents(from: events), as: .future, item: EventItem.event, to: &snapshot)

        apply(snapshot, animated: animated)
        updateFilterButton()
    }

    private func apply(_ snapshot: Snapshot, animated: Bool) {
        var updatedSnapshot = snapshot
        let oldItems = Set(dataSource.snapshot().itemIdentifiers)
        updatedSnapshot.reconfigureItems(snapshot.itemIdentifiers.filter { oldItems.contains($0) })
        dataSource.apply(updatedSnapshot, animatingDifferences: animated) { [weak self] in
            self?.refreshVisibleHeaders()
        }
    }

    private func refreshVisibleHeaders() {
        for indexPath in collectionView.indexPathsForVisibleSupplementaryElements(ofKind: UICollectionView.elementKindSectionHeader) {
            guard let section = section(at: indexPath.section), let title = section.title,
                  let header = collectionView.supplementaryView(
                    forElementKind: UICollectionView.elementKindSectionHeader, at: indexPath
                  ) as? EventSectionHeaderView else { continue }
            header.configure(title: title, count: sectionCounts[section, default: 0])
        }
    }

    @objc private func refreshEvents() {
        loadData()
    }

    @objc private func calendarDayChanged() {
        guard isViewLoaded, view.window != nil else { return }
        loadData()
    }

    @objc private func sceneDidActivate(_ notification: Notification) {
        guard let scene = notification.object as? UIWindowScene, scene === viewIfLoaded?.window?.windowScene else { return }
        if !calendar.isDate(referenceDate, inSameDayAs: now()) {
            loadData()
        } else {
            applySnapshot(animated: false)
        }
    }

    private func scheduleSearchUpdate() {
        searchUpdateTask?.cancel()

        searchUpdateTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }

            self?.applySnapshot(animated: false)
        }
    }

    private func updateFilterButton() {
        let imageName = filter.isEmpty
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
        navigationItem.rightBarButtonItem?.accessibilityLabel = filter.activeFilterCount == 0
            ? String(localized: "Filter")
            : String(localized: "Filter, \(filter.activeFilterCount) active", comment: "Accessibility label. The number is the count of active event filters.")
    }

    private func toggleQuickFilter(_ quickFilter: EventQuickFilter) {
        switch quickFilter {
        case .today:
            filter.dateScope = filter.dateScope == .today ? .all : .today
        case .tomorrow:
            filter.dateScope = filter.dateScope == .tomorrow ? .all : .tomorrow
        case .nextSevenDays:
            filter.dateScope = filter.dateScope == .nextSevenDays ? .all : .nextSevenDays
        case .weekend:
            filter.dateScope = filter.dateScope == .weekend ? .all : .weekend
        case .withImages:
            filter.onlyWithImages.toggle()
        case .favorites:
            filter.onlyFavorites.toggle()
        case .free:
            filter.onlyFree.toggle()
        case .online:
            filter.attendanceModes.toggle(EventAttendanceMode.online.rawValue)
        }

        applySnapshot(animated: true)
    }

    @objc private func showFilters() {
        let filterViewController = EventFilterViewController(
            filter: filter,
            options: EventFilterOptions(events: allEvents)
        )
        filterViewController.onApply = { [weak self] filter in
            self?.suppressCollectionSelectionsDuringSheetDismissal()
            self?.filter = filter
            self?.applySnapshot(animated: true)
        }

        let navigationController = UINavigationController(rootViewController: filterViewController)
        navigationController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = navigationController.sheetPresentationController {
            sheetPresentationController.detents = [.medium(), .large()]
            sheetPresentationController.prefersGrabberVisible = true
            sheetPresentationController.preferredCornerRadius = 24
        }

        present(navigationController, animated: true)
    }

    private func showEventDetailViewController(for event: Event) {
        view.endEditing(true)
        guard pendingSelectedEvent == nil else { return }
        if searchController.isActive || isDismissingSearch {
            pendingSelectedEvent = event
            searchUpdateTask?.cancel()
            searchController.isActive = false
            return
        }
        pushEventDetail(event)
    }

    private func pushEventDetail(_ event: Event) {
        let viewModel = EventDetailsViewModel(model: event)
        let detailViewController = EventDetailViewController(viewModel: viewModel)

        navigationController?.pushViewController(detailViewController, animated: true)
    }

    private func suppressCollectionSelectionsDuringSheetDismissal() {
        suppressCollectionSelectionsUntil = ProcessInfo.processInfo.systemUptime + 0.6
    }

    private var isSuppressingCollectionSelections: Bool {
        ProcessInfo.processInfo.systemUptime < suppressCollectionSelectionsUntil
    }
}

extension EventsViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard pendingSelectedEvent == nil else { return }
        searchText = searchController.searchBar.text ?? ""
        scheduleSearchUpdate()
    }
}

extension EventsViewController: UISearchControllerDelegate {
    func willDismissSearchController(_ searchController: UISearchController) {
        isDismissingSearch = true
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        isDismissingSearch = false
        guard let event = pendingSelectedEvent else { return }
        pendingSelectedEvent = nil
        searchController.searchBar.text = searchText
        pushEventDetail(event)
    }
}

extension EventsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isSuppressingCollectionSelections else {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }

        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .quickFilter(let quickFilter):
            collectionView.deselectItem(at: indexPath, animated: false)
            toggleQuickFilter(quickFilter)
        case .spotlight(let event), .event(let event):
            showEventDetailViewController(for: event)
        case .loading, .empty:
            break
        }
    }
}

private extension EventsViewController {

    private func append(
        _ events: [Event],
        as section: EventSection,
        item: (Event) -> EventItem,
        to snapshot: inout Snapshot
    ) {
        guard !events.isEmpty else { return }

        sectionCounts[section] = events.count
        snapshot.appendSections([section])
        snapshot.appendItems(events.map(item), toSection: section)
    }

    func visibleEvents() -> [Event] {
        let query = normalizedSearchText(searchText)

        return allEvents.filter { event in
            guard let start = event.startDate,
                  start.timeIntervalSinceReferenceDate >= calendar.startOfDay(for: referenceDate).timeIntervalSinceReferenceDate
                    || (event.endDate ?? start) > calendar.startOfDay(for: referenceDate),
                  filter.matches(event, calendar: calendar, now: referenceDate) else { return false }

            if query.isEmpty {
                return true
            }

            let searchableText = searchIndex[event.id] ?? EventFormatter.searchableText(for: event)
            return query.allSatisfy { searchableText.contains($0) }
        }
    }

    func spotlightEvents(from events: [Event]) -> [Event] {
        Array(events
            .filter { event in
                event.image != nil
                && (
                    EventFormatter.overlapsToday(event, calendar: calendar, now: referenceDate)
                    || EventFormatter.overlapsDay(event, dayOffset: 1, calendar: calendar, now: referenceDate)
                    || EventFormatter.isNextDaysEvent(event, calendar: calendar, now: referenceDate)
                )
            }
            .prefix(6))
    }

    func todayEvents(from events: [Event]) -> [Event] {
        events.filter { EventFormatter.overlapsToday($0, calendar: calendar, now: referenceDate) }
    }

    func tomorrowEvents(from events: [Event]) -> [Event] {
        events.filter {
            !EventFormatter.overlapsToday($0, calendar: calendar, now: referenceDate)
            && EventFormatter.overlapsDay($0, dayOffset: 1, calendar: calendar, now: referenceDate)
        }
    }

    func nextDaysEvents(from events: [Event]) -> [Event] {
        events.filter { EventFormatter.isNextDaysEvent($0, calendar: calendar, now: referenceDate) }
    }

    func futureEvents(from events: [Event]) -> [Event] {
        events.filter { EventFormatter.isFutureEvent($0, calendar: calendar, now: referenceDate) }
    }

    func emptyItem() -> EventItem {
        if let errorMessage {
            return .empty(
                title: String(localized: "Events could not be loaded"),
                message: errorMessage
            )
        }

        if filter.isEmpty && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .empty(
                title: String(localized: "No events found"),
                message: String(localized: "New events will appear here when they become available.")
            )
        }

        return .empty(
            title: String(localized: "No results"),
            message: String(localized: "Change your search or filters to see more events.")
        )
    }

    func sorted(_ events: [Event]) -> [Event] {
        events.sorted { first, second in
            switch (first.startDate, second.startDate) {
            case let (firstDate?, secondDate?):
                if firstDate == secondDate {
                    return first.name.localizedStandardCompare(second.name) == .orderedAscending
                }

                return firstDate < secondDate
            case (.some, .none):
                return true
            case (.none, .some):
                return false
            case (.none, .none):
                return first.name.localizedStandardCompare(second.name) == .orderedAscending
            }
        }
    }

    func normalizedSearchText(_ value: String) -> [String] {
        EventSearchTextNormalizer().normalize(value).split(whereSeparator: \.isWhitespace).map(String.init)
    }

    func isEmphasized(_ event: Event) -> Bool {
        EventFormatter.overlapsToday(event, calendar: calendar, now: referenceDate) || EventFormatter.overlapsDay(event, dayOffset: 1, calendar: calendar, now: referenceDate)
    }

    func section(at index: Int) -> EventSection? {
        guard dataSource != nil else { return nil }

        let sections = dataSource.snapshot().sectionIdentifiers
        guard sections.indices.contains(index) else { return nil }

        return sections[index]
    }

    func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self, let section = self.section(at: sectionIndex) else {
                return Self.listSectionLayout(hasHeader: false)
            }

            switch section {
            case .loading, .empty:
                return Self.cardSectionLayout(height: 220)
            case .quickFilters:
                return Self.quickFilterSectionLayout(environment: environment)
            case .spotlights:
                return Self.spotlightSectionLayout(environment: environment)
            case .today, .tomorrow, .nextDays, .future:
                return Self.listSectionLayout(hasHeader: true)
            }
        }
    }

    static func quickFilterSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let usesVerticalRows = environment.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let itemSize = NSCollectionLayoutSize(
            widthDimension: usesVerticalRows ? .fractionalWidth(1) : .estimated(104),
            heightDimension: .estimated(34)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = usesVerticalRows ? .none : .continuous
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20)

        return section
    }

    static func spotlightSectionLayout(environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let usesVerticalRows = environment.traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(138)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: usesVerticalRows ? .fractionalWidth(1) : .absolute(
                max(1, min(environment.container.effectiveContentSize.width * 0.88,
                           environment.container.effectiveContentSize.width - 40))
            ),
            heightDimension: .estimated(138)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = usesVerticalRows ? .none : .continuousGroupLeadingBoundary
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 18, trailing: 20)
        section.boundarySupplementaryItems = [sectionHeader()]

        return section
    }

    static func listSectionLayout(hasHeader: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(80)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 7
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 20, bottom: 18, trailing: 20)

        if hasHeader {
            section.boundarySupplementaryItems = [sectionHeader()]
        }

        return section
    }

    static func cardSectionLayout(height: CGFloat) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(height)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 20, trailing: 20)

        return section
    }

    static func sectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .estimated(34)
            ),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }

}

#Preview("Events without a service") {
    UINavigationController(rootViewController: EventsViewController())
}
