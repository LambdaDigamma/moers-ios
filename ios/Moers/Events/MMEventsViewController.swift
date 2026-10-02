//
//  MMEventsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.06.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Core
import MMEvents
import OSLog
import UIKit
import SwiftUI

@MainActor
final class MMEventsViewController: UIViewController, TabBarItemProvider, CoordinatorAssignable {

    public var coordinator: EventCoordinator?

    private typealias DataSource = UICollectionViewDiffableDataSource<MMEventSection, MMEventItem>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<MMEventSection, MMEventItem>

    private let logger = Logger(.coreUi)
    private let searchController = UISearchController(searchResultsController: nil)

    private var collectionView: UICollectionView!
    private var dataSource: DataSource!
    private var loadTask: Task<Void, Never>?
    private var searchUpdateTask: Task<Void, Never>?

    private var allEvents: [Event] = []
    private var searchIndex: [Event.ID: String] = [:]
    private var filter = MMEventFilter()
    private var searchText = ""
    private var isLoading = true
    private var errorMessage: String?
    private var sectionCounts: [MMEventSection: Int] = [:]
    private var suppressCollectionSelectionsUntil: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        configureSearch()
        configureCollectionView()
        configureDataSource()
        applySnapshot(animated: false)
        loadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        UserActivity.current = UserActivities.configureEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                collectionView.deselectItem(at: indexPath, animated: animated)
            }
        }

        collectionView.reloadData()
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Veranstaltungen suchen"
        searchController.searchBar.searchTextField.clearButtonMode = .whileEditing

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        collectionView.backgroundColor = .systemGroupedBackground
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            MMEventLoadingCell.self,
            forCellWithReuseIdentifier: MMEventLoadingCell.reuseIdentifier
        )
        collectionView.register(
            MMEventQuickFilterCell.self,
            forCellWithReuseIdentifier: MMEventQuickFilterCell.reuseIdentifier
        )
        collectionView.register(
            MMEventSpotlightCell.self,
            forCellWithReuseIdentifier: MMEventSpotlightCell.reuseIdentifier
        )
        collectionView.register(
            MMEventListCell.self,
            forCellWithReuseIdentifier: MMEventListCell.reuseIdentifier
        )
        collectionView.register(
            MMEventEmptyCell.self,
            forCellWithReuseIdentifier: MMEventEmptyCell.reuseIdentifier
        )
        collectionView.register(
            MMEventSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: MMEventSectionHeaderView.reuseIdentifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
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
                    withReuseIdentifier: MMEventLoadingCell.reuseIdentifier,
                    for: indexPath
                ) as! MMEventLoadingCell
                cell.startAnimating()
                return cell
            case .quickFilter(let quickFilter):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MMEventQuickFilterCell.reuseIdentifier,
                    for: indexPath
                ) as! MMEventQuickFilterCell
                cell.configure(with: quickFilter, isSelected: quickFilter.isSelected(in: filter))
                return cell
            case .spotlight(let event):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MMEventSpotlightCell.reuseIdentifier,
                    for: indexPath
                ) as! MMEventSpotlightCell
                cell.configure(with: event)
                return cell
            case .event(let event):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MMEventListCell.reuseIdentifier,
                    for: indexPath
                ) as! MMEventListCell
                cell.configure(with: event, emphasized: isEmphasized(event))
                return cell
            case .empty(let title, let message):
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: MMEventEmptyCell.reuseIdentifier,
                    for: indexPath
                ) as! MMEventEmptyCell
                cell.configure(title: title, message: message)
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
                withReuseIdentifier: MMEventSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as! MMEventSectionHeaderView
            headerView.configure(title: title, count: self.sectionCounts[section, default: 0])

            return headerView
        }
    }

    private func loadData() {
        guard let eventService = coordinator?.eventService else {
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
                let response = try await eventService.index(cacheMode: .revalidate, withPages: false)
                let events = response.data

                guard !Task.isCancelled else { return }

                self?.handleLoadedEvents(events)
            } catch {
                guard !Task.isCancelled else { return }

                logger.error("Error while loading events: \(error.localizedDescription)")
                self?.handleLoadingError(error)
            }
        }
    }

    private func handleLoadedEvents(_ events: [Event]) {
        allEvents = sorted(events)
        searchIndex = Dictionary(uniqueKeysWithValues: allEvents.map { event in
            (event.id, MMEventFormatter.searchableText(for: event))
        })
        isLoading = false
        errorMessage = nil
        applySnapshot(animated: true)
    }

    private func handleLoadingError(_ error: Error) {
        isLoading = false
        errorMessage = error.localizedDescription
        applySnapshot(animated: true)
    }

    private func applySnapshot(animated: Bool) {
        sectionCounts = [:]

        var snapshot = Snapshot()

        if isLoading {
            snapshot.appendSections([.loading])
            snapshot.appendItems([.loading], toSection: .loading)
            dataSource.apply(snapshot, animatingDifferences: animated)
            return
        }

        snapshot.appendSections([.quickFilters])
        snapshot.appendItems(MMEventQuickFilter.allCases.map { .quickFilter($0) }, toSection: .quickFilters)

        let events = visibleEvents()

        if events.isEmpty {
            snapshot.appendSections([.empty])
            snapshot.appendItems([emptyItem()], toSection: .empty)
            dataSource.apply(snapshot, animatingDifferences: animated)
            updateFilterButton()
            return
        }

        let spotlights = spotlightEvents(from: events)
        if !spotlights.isEmpty {
            append(spotlights, as: .spotlights, item: MMEventItem.spotlight, to: &snapshot)
        }

        append(todayEvents(from: events), as: .today, item: MMEventItem.event, to: &snapshot)
        append(tomorrowEvents(from: events), as: .tomorrow, item: MMEventItem.event, to: &snapshot)
        append(nextDaysEvents(from: events), as: .nextDays, item: MMEventItem.event, to: &snapshot)
        append(futureEvents(from: events), as: .future, item: MMEventItem.event, to: &snapshot)

        dataSource.apply(snapshot, animatingDifferences: animated)
        updateFilterButton()
    }

    private func append(
        _ events: [Event],
        as section: MMEventSection,
        item: (Event) -> MMEventItem,
        to snapshot: inout Snapshot
    ) {
        guard !events.isEmpty else { return }

        sectionCounts[section] = events.count
        snapshot.appendSections([section])
        snapshot.appendItems(events.map(item), toSection: section)
    }

    private func visibleEvents() -> [Event] {
        let query = normalizedSearchText(searchText)

        return allEvents.filter { event in
            guard filter.matches(event) else { return false }

            if query.isEmpty {
                return true
            }

            let searchableText = searchIndex[event.id] ?? MMEventFormatter.searchableText(for: event)
            return query.allSatisfy { searchableText.contains($0) }
        }
    }

    private func spotlightEvents(from events: [Event]) -> [Event] {
        Array(events
            .filter { event in
                event.image != nil
                && (
                    MMEventFormatter.overlapsToday(event)
                    || MMEventFormatter.overlapsDay(event, dayOffset: 1)
                    || MMEventFormatter.isNextDaysEvent(event)
                )
            }
            .prefix(6))
    }

    private func todayEvents(from events: [Event]) -> [Event] {
        events.filter { MMEventFormatter.overlapsToday($0) }
    }

    private func tomorrowEvents(from events: [Event]) -> [Event] {
        events.filter {
            !MMEventFormatter.overlapsToday($0)
            && MMEventFormatter.overlapsDay($0, dayOffset: 1)
        }
    }

    private func nextDaysEvents(from events: [Event]) -> [Event] {
        events.filter { MMEventFormatter.isNextDaysEvent($0) }
    }

    private func futureEvents(from events: [Event]) -> [Event] {
        events.filter { MMEventFormatter.isFutureEvent($0) }
    }

    private func emptyItem() -> MMEventItem {
        if let errorMessage {
            return .empty(
                title: "Veranstaltungen konnten nicht geladen werden",
                message: errorMessage
            )
        }

        if filter.isEmpty && searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return .empty(
                title: "Keine Veranstaltungen gefunden",
                message: "Sobald neue Termine verfügbar sind, erscheinen sie hier."
            )
        }

        return .empty(
            title: "Keine Treffer",
            message: "Passe Suche oder Filter an, um mehr Veranstaltungen zu sehen."
        )
    }

    private func sorted(_ events: [Event]) -> [Event] {
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

    private func normalizedSearchText(_ value: String) -> [String] {
        value
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .split(separator: " ")
            .map(String.init)
    }

    private func scheduleSearchUpdate() {
        searchUpdateTask?.cancel()

        searchUpdateTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(120))
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self?.applySnapshot(animated: false)
            }
        }
    }

    private func isEmphasized(_ event: Event) -> Bool {
        MMEventFormatter.overlapsToday(event) || MMEventFormatter.overlapsDay(event, dayOffset: 1)
    }

    private func section(at index: Int) -> MMEventSection? {
        guard dataSource != nil else { return nil }

        let sections = dataSource.snapshot().sectionIdentifiers
        guard sections.indices.contains(index) else { return nil }

        return sections[index]
    }

    private func updateFilterButton() {
        let imageName = filter.isEmpty
            ? "line.3.horizontal.decrease.circle"
            : "line.3.horizontal.decrease.circle.fill"
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
        navigationItem.rightBarButtonItem?.accessibilityLabel = filter.activeFilterCount == 0
            ? "Filter"
            : "Filter, \(filter.activeFilterCount) aktiv"
    }

    private func toggleQuickFilter(_ quickFilter: MMEventQuickFilter) {
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
            filter.attendanceModes.toggle(MMEventAttendanceMode.online.rawValue)
        }

        applySnapshot(animated: true)
    }

    @objc private func showFilters() {
        let filterViewController = MMEventFilterViewController(
            filter: filter,
            options: MMEventFilterOptions(events: allEvents)
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
        searchController.isActive = false
        view.endEditing(true)

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

extension MMEventsViewController: UISearchResultsUpdating {

    nonisolated func updateSearchResults(for searchController: UISearchController) {
        Task { @MainActor [weak self] in
            self?.searchText = searchController.searchBar.text ?? ""
            self?.scheduleSearchUpdate()
        }
    }
}

extension MMEventsViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard !isSuppressingCollectionSelections else {
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }

        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .quickFilter(let quickFilter):
            toggleQuickFilter(quickFilter)
        case .spotlight(let event), .event(let event):
            showEventDetailViewController(for: event)
        case .loading, .empty:
            break
        }
    }
}

private extension MMEventsViewController {

    func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self, let section = self.section(at: sectionIndex) else {
                return Self.listSectionLayout(hasHeader: false)
            }

            switch section {
            case .loading, .empty:
                return Self.cardSectionLayout(height: 220)
            case .quickFilters:
                return Self.quickFilterSectionLayout()
            case .spotlights:
                return Self.spotlightSectionLayout()
            case .today, .tomorrow, .nextDays, .future:
                return Self.listSectionLayout(hasHeader: true)
            }
        }
    }

    static func quickFilterSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .estimated(104),
            heightDimension: .absolute(34)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: itemSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 20, bottom: 12, trailing: 20)

        return section
    }

    static func spotlightSectionLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.88),
            heightDimension: .absolute(138)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
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
    UINavigationController(rootViewController: MMEventsViewController())
}
