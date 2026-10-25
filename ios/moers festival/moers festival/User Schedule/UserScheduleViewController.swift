import UIKit
import SwiftUI
import FactoryKit
import Events
import Combine

final class UserScheduleViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    @LazyInjected(\.favoriteEventsStore) private var favoriteEventsStore

    @PersistedFilter(key: "favoritesFilter") var filter: EventFilter {
        didSet { reload() }
    }

    var onShowEvent: ((Event.ID) -> Void)?
    var selectedEventID: Event.ID? {
        didSet {
            guard isViewLoaded else { return }
            for case let cell as TimetableDayPageCell in collectionView.visibleCells {
                cell.selectedEventID = selectedEventID
            }
        }
    }
    private(set) var days: [UserScheduleDay] = []
    private(set) var selectedDay: UserScheduleDay?

    private var favorites: [FavoriteEventInfo] = []
    private var modelsByEventID: [Event.ID: EventListItemViewModel] = [:]
    private var eventsByDay: [UserScheduleDay: [EventListItemViewModel]] = [:]
    private var favoritesCancellable: AnyCancellable?
    private var filterCancellable: AnyCancellable?
    private var dataSource: UICollectionViewDiffableDataSource<Int, UserScheduleDay>!
    private let topAccessory = TimetableTopAccessoryView()
    private var palette: UIView?
    private var paletteHeight: CGFloat = 0
    private var lastPageSize: CGSize = .zero

    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collection = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.isPagingEnabled = true
        collection.showsHorizontalScrollIndicator = false
        collection.contentInsetAdjustmentBehavior = .never
        collection.backgroundColor = .systemBackground
        collection.delegate = self
        return collection
    }()

    private lazy var mainStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [collectionView])
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    nonisolated deinit {}

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedLayoutIncludesOpaqueBars = true
        view.backgroundColor = .systemBackground
        view.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: view.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        setupDataSource()
        setupActions()
        reload()
        favoritesCancellable = favoriteEventsStore?.observeFavoriteEvents()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] events in
                self?.favorites = events
                self?.reload()
            })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePaletteHeight()
        if collectionView.bounds.size != lastPageSize {
            lastPageSize = collectionView.bounds.size
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutIfNeeded()
            scrollToSelection(animated: false)
        }
    }

    private func setupDataSource() {
        let registration = UICollectionView.CellRegistration<TimetableDayPageCell, UserScheduleDay> { [weak self] cell, _, day in
            guard let self else { return }
            cell.configure(
                events: self.eventsByDay[day] ?? [],
                isFilterActive: !self.filter.isEmpty,
                displayMode: .compact,
                showsFavoriteIcon: false,
                onSelectEvent: { [weak self] eventID in self?.showEvent(eventID) }
            )
            cell.selectedEventID = self.selectedEventID
        }
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView) { collection, indexPath, day in
            collection.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: day)
        }
    }

    private func setupActions() {
        let filterButton = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            primaryAction: UIAction { [weak self] _ in self?.showFilter() }
        )
        filterButton.accessibilityLabel = EventPackageStrings.filter
        navigationItem.rightBarButtonItem = filterButton
        topAccessory.onClearFilter = { [weak self] in self?.filter = .empty }
        topAccessory.bubbleView.onSelectDate = { [weak self] date in self?.selectDay(.scheduled(date)) }
        topAccessory.bubbleView.onSelectUnscheduled = { [weak self] in self?.selectDay(.unscheduled) }
    }

    func reload() {
        guard isViewLoaded else { return }
        let visibleFavorites = favorites.filter { info in
            if filter.venueIDs.isEmpty { return true }
            guard let placeID = info.place?.id else { return false }
            return filter.venueIDs.contains(Int(placeID))
        }
        var grouped: [UserScheduleDay: [EventListItemViewModel]] = [:]
        var currentModels: [Event.ID: EventListItemViewModel] = [:]
        for info in visibleFavorites {
            let event = info.event.toBase()
            let model = modelsByEventID[event.id] ?? EventListItemViewModel(eventID: event.id, title: event.name)
            model.title = event.name
            model.startDate = event.startDate
            model.endDate = event.endDate
            model.location = info.place?.name
            model.isOpenEnd = event.extras?.openEnd ?? false
            model.scheduleDisplayMode = event.scheduleDisplayMode
            model.isLiked = true
            currentModels[event.id] = model
            grouped[UserScheduleDay(startDate: event.startDate), default: []].append(model)
        }
        modelsByEventID = currentModels
        eventsByDay = grouped
        days = grouped.keys.sorted { ($0.date ?? .distantFuture) < ($1.date ?? .distantFuture) }
        if selectedDay.map({ !days.contains($0) }) ?? true {
            selectedDay = days.first
        }
        updateAccessory()
        updateEmptyState()
        var snapshot = NSDiffableDataSourceSnapshot<Int, UserScheduleDay>()
        snapshot.appendSections([0])
        snapshot.appendItems(days)
        snapshot.reconfigureItems(days)
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.scrollToSelection(animated: false)
            self?.updateContentScrollView()
        }
    }

    func selectDay(_ day: UserScheduleDay) {
        guard days.contains(day) else { return }
        selectedDay = day
        topAccessory.bubbleView.setSelectedDate(day.date, animated: !UIAccessibility.isReduceMotionEnabled)
        scrollToSelection(animated: !UIAccessibility.isReduceMotionEnabled)
    }

    private func updateAccessory() {
        let isFilterActive = !filter.isEmpty
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: isFilterActive
            ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
        topAccessory.setFilterActive(isFilterActive)
        topAccessory.bubbleView.isHidden = days.isEmpty
        topAccessory.bubbleView.setDates(
            days.compactMap(\.date),
            selectedDate: selectedDay?.date,
            includesUnscheduled: days.contains(.unscheduled)
        )
        if !days.isEmpty || isFilterActive {
            if palette == nil {
                palette = NavigationBarPalette.make(contentView: topAccessory, preferredHeight: accessoryHeight())
                navigationItem.timetableBottomPalette = palette
            }
        } else {
            navigationItem.timetableBottomPalette = nil
            palette = nil
            paletteHeight = 0
        }
        updatePaletteHeight()
    }

    private func accessoryHeight() -> CGFloat {
        topAccessory.systemLayoutSizeFitting(
            CGSize(width: view.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
    }

    private func updatePaletteHeight() {
        guard let palette else { return }
        let height = accessoryHeight()
        guard abs(height - paletteHeight) > 0.5 else { return }
        paletteHeight = height
        NavigationBarPalette.setPreferredHeight(height, of: palette)
    }

    private func updateEmptyState() {
        guard days.isEmpty else {
            collectionView.backgroundView = nil
            return
        }
        var configuration = UIContentUnavailableConfiguration.empty()
        configuration.image = UIImage(systemName: "heart.slash")
        configuration.text = filter.isEmpty
            ? String(localized: "No event has been marked as a favorite yet.")
            : EventPackageStrings.noFavoriteEventsForFilter
        collectionView.backgroundView = UIContentUnavailableView(configuration: configuration)
    }

    private var currentPageIndex: Int? {
        collectionView.indexPathForItem(at: CGPoint(x: collectionView.bounds.midX, y: collectionView.bounds.midY))?.item
    }

    private func scrollToSelection(animated: Bool) {
        guard !collectionView.isDragging, !collectionView.isDecelerating,
              collectionView.bounds.width > 0, let selectedDay,
              let index = dataSource.snapshot().itemIdentifiers.firstIndex(of: selectedDay) else { return }
        let selectedOffset = CGFloat(index) * collectionView.bounds.width
        if abs(collectionView.contentOffset.x - selectedOffset) > 0.5 {
            collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
        }
        if !animated { updateContentScrollView() }
    }

    private func updateContentScrollView() {
        guard let index = currentPageIndex,
              let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? TimetableDayPageCell else { return }
        setContentScrollView(cell.listView)
    }

    private func showEvent(_ eventID: Event.ID) {
        if let onShowEvent {
            onShowEvent(eventID)
        } else {
            navigationController?.pushViewController(ModernEventDetailViewController(eventID: eventID), animated: true)
        }
    }

    private func showFilter() {
        let box = FilterBox(filter: filter)
        filterCancellable = box.$filter.removeDuplicates().receive(on: DispatchQueue.main).sink { [weak self] value in
            self?.filter = value
        }
        present(UIHostingController(rootView: EventFilterSheetWrapper(box: box, isFavoritesFilterEnabled: false)), animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        collectionView.bounds.size
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === collectionView, scrollView.isDragging || scrollView.isDecelerating,
              let index = currentPageIndex, days.indices.contains(index) else { return }
        selectedDay = days[index]
        topAccessory.bubbleView.setSelectedDate(selectedDay?.date, animated: false)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateContentScrollView()
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateContentScrollView()
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        updateContentScrollView()
    }
}
