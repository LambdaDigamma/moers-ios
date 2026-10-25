//
//  TimetableViewController.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

#if !os(tvOS)

import UIKit
import Combine
import SwiftUI
import Observation

public class TimetableViewController: UIViewController {

    private enum Content {
        case pages
        case venueGrid
        case previewList
    }

    private struct PagesState: Equatable {
        var dates: [Date]
        var eventIDs: [[UUID]]
        var isFilterActive: Bool
        var displayMode: DailyEventsDisplayMode
    }

    private let transmitter: TimetableTransmitter
    private let viewModel: TimetableViewModel

    private let topAccessory = TimetableTopAccessoryView()
    private var palette: UIView?
    private var paletteHeight: CGFloat = 0

    private var pagesView: UICollectionView!
    private var pagesDataSource: UICollectionViewDiffableDataSource<Int, Date>!
    private var pagesState: PagesState?
    private var lastPagesSize: CGSize = .zero

    private var hostedContent: UIHostingController<AnyView>?
    private var hostedContentKind: Content?

    private var cancellables = Set<AnyCancellable>()

    public var onShowEvent: ((Event.ID) -> Void)?
    public var searchDetailViewControllerFactory: ((Event.ID) -> UIViewController)?

    public var selectedEventID: Event.ID? {
        get { transmitter.selectedEventID }
        set {
            guard transmitter.selectedEventID != newValue else { return }
            transmitter.selectedEventID = newValue
            for case let cell as TimetableDayPageCell in pagesView?.visibleCells ?? [] {
                cell.selectedEventID = newValue
            }
        }
    }

    private var displayMode: DailyEventsDisplayMode {
        DailyEventsDisplayMode(rawValue: UserDefaults.standard.integer(forKey: "currentEventDisplayMode")) ?? .compact
    }

    public init() {
        self.transmitter = TimetableTransmitter()
        self.viewModel = TimetableViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.extendedLayoutIncludesOpaqueBars = true

        self.setupUI()
        self.setupPages()
        self.setupTransmitter()
        self.setupObservers()

        self.render()

        Task { [viewModel] in
            await viewModel.load()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updatePaletteHeight()

        if pagesView.bounds.size != lastPagesSize {
            lastPagesSize = pagesView.bounds.size
            pagesView.collectionViewLayout.invalidateLayout()
            pagesView.layoutIfNeeded()
            scrollToSelectedPage(animated: false)
        }
    }

    // MARK: - Setup

    private func setupUI() {

        view.backgroundColor = .systemBackground

        navigationItem.title = EventPackageStrings.timetable
        navigationItem.largeTitleDisplayMode = .never

        topAccessory.bubbleView.onSelectDate = { [weak self] date in
            self?.viewModel.selectDate(date)
        }
        topAccessory.onClearFilter = { [weak self] in
            self?.viewModel.filter = .empty
        }

        updateBarButtonItems()

    }

    private func setupPages() {

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        pagesView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        pagesView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pagesView.backgroundColor = .clear
        pagesView.isPagingEnabled = true
        pagesView.showsHorizontalScrollIndicator = false
        pagesView.contentInsetAdjustmentBehavior = .never
        pagesView.delegate = self
        view.addSubview(pagesView)

        let registration = UICollectionView.CellRegistration<TimetableDayPageCell, Date> { [weak self] cell, _, date in
            guard let self else { return }

            cell.configure(
                day: self.viewModel.days.first { $0.date == date },
                isFilterActive: !self.viewModel.filter.isEmpty,
                displayMode: self.displayMode,
                onRefresh: { [viewModel = self.viewModel] in await viewModel.refresh() },
                onSelectEvent: { [weak self] eventID in self?.onShowEvent?(eventID) }
            )
            cell.selectedEventID = self.selectedEventID
        }

        pagesDataSource = UICollectionViewDiffableDataSource(collectionView: pagesView) { collectionView, indexPath, date in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: date)
        }

    }

    private func setupTransmitter() {

        self.transmitter.showEvent.sink { [weak self] (eventID: Event.ID) in
            self?.onShowEvent?(eventID)
        }
        .store(in: &cancellables)

        self.transmitter.searchRequested.sink { [weak self] in
            self?.presentSearch()
        }
        .store(in: &cancellables)

    }

    private func setupObservers() {

        track { [weak self] in
            self?.render()
        }

        NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.render()
            }
            .store(in: &cancellables)

    }

    /// Re-runs `apply` whenever an observable property it reads changes.
    private func track(_ apply: @escaping @MainActor @Sendable () -> Void) {
        withObservationTracking {
            apply()
        } onChange: { [weak self] in
            Task { @MainActor in
                self?.track(apply)
            }
        }
    }

    // MARK: - Rendering

    private func render() {

        let days = viewModel.days
        let dates = days.map(\.date)
        let isFilterActive = !viewModel.filter.isEmpty
        let hidesSchedule = viewModel.allEventsHideSchedule
        let displayMode = self.displayMode

        _ = viewModel.selectedDate

        let content: Content = hidesSchedule ? .previewList : (displayMode == .venueGrid ? .venueGrid : .pages)

        updateBarButtonItems()
        updateHostedContent(content)
        pagesView.isHidden = content != .pages

        topAccessory.setFilterActive(isFilterActive)
        topAccessory.bubbleView.isHidden = dates.isEmpty || hidesSchedule
        topAccessory.bubbleView.setDates(dates, selectedDate: viewModel.selectedDate)
        setAccessoryVisible(!topAccessory.bubbleView.isHidden || isFilterActive)

        let state = PagesState(
            dates: dates,
            eventIDs: days.map { $0.events.map(\.id) },
            isFilterActive: isFilterActive,
            displayMode: displayMode
        )

        if state != pagesState {
            pagesState = state

            var snapshot = NSDiffableDataSourceSnapshot<Int, Date>()
            snapshot.appendSections([0])
            snapshot.appendItems(dates)
            snapshot.reconfigureItems(dates)
            pagesDataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
                self?.scrollToSelectedPage(animated: false)
                self?.updateContentScrollView()
            }

        } else {
            scrollToSelectedPage(animated: !UIAccessibility.isReduceMotionEnabled && view.window != nil)
        }

        updatePaletteHeight()

    }

    private func updateHostedContent(_ content: Content) {

        guard hostedContentKind != content else { return }
        hostedContentKind = content

        if let hostedContent {
            hostedContent.willMove(toParent: nil)
            hostedContent.view.removeFromSuperview()
            hostedContent.removeFromParent()
            self.hostedContent = nil
        }

        let rootView: AnyView
        switch content {
            case .pages:
                return
            case .venueGrid:
                rootView = VenueEventsGrid(viewModel: viewModel).environment(transmitter).toAnyView()
            case .previewList:
                rootView = PreviewListEventsView().environment(transmitter).toAnyView()
        }

        let hosting = UIHostingController(rootView: rootView)
        addChild(hosting)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.view.backgroundColor = .clear
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        hostedContent = hosting

    }

    private func setAccessoryVisible(_ isVisible: Bool) {

        if isVisible, palette == nil {
            let height = accessoryHeight()
            paletteHeight = height
            palette = NavigationBarPalette.make(contentView: topAccessory, preferredHeight: height)
            navigationItem.timetableBottomPalette = palette
        } else if !isVisible, palette != nil {
            palette = nil
            paletteHeight = 0
            navigationItem.timetableBottomPalette = nil
        }

    }

    private func accessoryHeight() -> CGFloat {
        let width = view.bounds.width
        return topAccessory.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
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

    private func updateBarButtonItems() {

        let search = UIBarButtonItem(
            image: UIImage(systemName: "magnifyingglass"),
            primaryAction: UIAction { [weak self] _ in self?.presentSearch() }
        )
        search.accessibilityLabel = EventPackageStrings.searchEvents

        let isFilterActive = !viewModel.filter.isEmpty
        let filter = UIBarButtonItem(
            image: UIImage(systemName: isFilterActive ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"),
            primaryAction: UIAction { [weak self] _ in self?.presentFilter() }
        )
        filter.accessibilityLabel = EventPackageStrings.filter

        navigationItem.rightBarButtonItems = [filter, search]

    }

    // MARK: - Page synchronisation

    private var currentPageIndex: Int? {
        pagesView.indexPathForItem(at: CGPoint(x: pagesView.bounds.midX, y: pagesView.bounds.midY))?.item
    }

    private func scrollToSelectedPage(animated: Bool) {

        guard pagesView.bounds.width > 0 else { return }
        guard !pagesView.isDragging, !pagesView.isDecelerating else { return }

        let dates = pagesState?.dates ?? []
        guard let index = dates.firstIndex(where: {
            Calendar.autoupdatingCurrent.isDate($0, inSameDayAs: viewModel.selectedDate)
        }) else {
            return
        }

        let selectedOffset = CGFloat(index) * pagesView.bounds.width
        guard abs(pagesView.contentOffset.x - selectedOffset) > 0.5 else { return }

        pagesView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)

        if !animated {
            updateContentScrollView()
        }

    }

    /// Lets the navigation bar follow the list of the page that is currently visible.
    private func updateContentScrollView() {

        guard hostedContentKind == .pages else {
            setContentScrollView(nil)
            return
        }

        guard
            let index = currentPageIndex,
            let cell = pagesView.cellForItem(at: IndexPath(item: index, section: 0)) as? TimetableDayPageCell
        else {
            return
        }

        setContentScrollView(cell.listView)

    }

    private func selectPageFromScrolling() {

        guard let index = currentPageIndex, let dates = pagesState?.dates, dates.indices.contains(index) else { return }
        guard !Calendar.autoupdatingCurrent.isDate(dates[index], inSameDayAs: viewModel.selectedDate) else { return }

        viewModel.selectDate(dates[index])

    }

    // MARK: - Presentation

    private func presentFilter() {

        let viewModel = self.viewModel
        let sheet = EventFilterSheet(filter: Binding(
            get: { viewModel.filter },
            set: { viewModel.filter = $0 }
        ))

        present(UIHostingController(rootView: sheet), animated: true)

    }

    private func presentSearch() {

        guard presentedViewController == nil else {
            return
        }

        guard let searchDetailViewControllerFactory else {
            assertionFailure("searchDetailViewControllerFactory must be configured before presenting search.")
            return
        }

        viewModel.beginSearch()

        let searchViewController = TimetableSearchViewController(
            viewModel: viewModel,
            detailViewControllerFactory: searchDetailViewControllerFactory
        )
        let navigationController = UINavigationController(rootViewController: searchViewController)

        present(navigationController, animated: true)
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

extension TimetableViewController: UICollectionViewDelegateFlowLayout {

    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        collectionView.bounds.size
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView === pagesView, scrollView.isDragging || scrollView.isDecelerating else { return }
        selectPageFromScrolling()
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView === pagesView else { return }
        updateContentScrollView()
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView === pagesView else { return }
        updateContentScrollView()
    }

    public func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        updateContentScrollView()
    }

}

#endif
