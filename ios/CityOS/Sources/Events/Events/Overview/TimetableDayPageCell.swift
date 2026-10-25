//
//  TimetableDayPageCell.swift
//
//
//  Created by Claude on 24.10.26.
//

#if !os(tvOS)

import SwiftUI
import UIKit

/// One page of the timetable: the events of a single day in a vertical list.
public final class TimetableDayPageCell: UICollectionViewCell, UICollectionViewDelegate {

    public private(set) var listView: UICollectionView!

    public var selectedEventID: Event.ID? {
        didSet { updateSelection() }
    }

    private var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    private var eventsByID: [UUID: EventListItemViewModel] = [:]
    private var displayMode: DailyEventsDisplayMode = .compact
    private var showsFavoriteIcon = true
    private var onSelectEvent: ((Event.ID) -> Void)?
    private var onRefresh: (() async -> Void)?

    private lazy var emptyView = makeEmptyView()

    nonisolated deinit {}

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupListView()
        setupDataSource()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        day: TimetableDay?,
        isFilterActive: Bool,
        displayMode: DailyEventsDisplayMode,
        onRefresh: @escaping () async -> Void,
        onSelectEvent: @escaping (Event.ID) -> Void
    ) {
        configure(
            events: day?.events ?? [],
            isFilterActive: isFilterActive,
            displayMode: displayMode,
            onRefresh: onRefresh,
            onSelectEvent: onSelectEvent
        )
    }

    public func configure(
        events: [EventListItemViewModel],
        isFilterActive: Bool,
        displayMode: DailyEventsDisplayMode,
        showsFavoriteIcon: Bool = true,
        onRefresh: (() async -> Void)? = nil,
        onSelectEvent: @escaping (Event.ID) -> Void
    ) {
        let modeChanged = self.displayMode != displayMode || self.showsFavoriteIcon != showsFavoriteIcon
        self.displayMode = displayMode
        self.showsFavoriteIcon = showsFavoriteIcon
        self.onRefresh = onRefresh
        self.onSelectEvent = onSelectEvent

        if onRefresh == nil {
            listView.refreshControl = nil
        } else if listView.refreshControl == nil {
            listView.refreshControl = makeRefreshControl()
        }
        eventsByID = Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(events.map(\.id))
        if modeChanged {
            snapshot.reconfigureItems(events.map(\.id))
            listView.collectionViewLayout.invalidateLayout()
        }
        dataSource.apply(snapshot, animatingDifferences: false) { [weak self] in
            self?.updateSelection()
        }

        listView.backgroundView = events.isEmpty && isFilterActive ? emptyView : nil
    }

    // MARK: - Setup

    private func setupListView() {
        let layout = UICollectionViewCompositionalLayout { [weak self] _, environment in
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.showsSeparators = self?.displayMode != .images
            configuration.backgroundColor = .clear
            return NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
        }

        listView = UICollectionView(frame: contentView.bounds, collectionViewLayout: layout)
        listView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        listView.backgroundColor = .systemBackground
        listView.delegate = self
        listView.alwaysBounceVertical = true
        contentView.addSubview(listView)
    }

    private func makeRefreshControl() -> UIRefreshControl {
        UIRefreshControl(frame: .zero, primaryAction: UIAction { [weak self] action in
            guard let refreshControl = action.sender as? UIRefreshControl else { return }
            Task { @MainActor in
                await self?.onRefresh?()
                refreshControl.endRefreshing()
            }
        })
    }

    private func setupDataSource() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, UUID> { [weak self] cell, _, id in
            guard let viewModel = self?.eventsByID[id] else { return }
            let isImages = self?.displayMode == .images

            cell.contentConfiguration = UIHostingConfiguration {
                if isImages {
                    EventCard(viewModel: viewModel)
                } else {
                    EventListItem(viewModel: viewModel)
                        .showFavoriteIcon(self?.showsFavoriteIcon ?? true)
                }
            }
            .margins(.horizontal, isImages ? 16 : 20)
            .margins(.vertical, isImages ? 8 : 12)

            if #available(iOS 18.0, *) {
                cell.backgroundConfiguration = .listCell()
            } else {
                cell.backgroundConfiguration = .listPlainCell()
            }
            cell.accessibilityIdentifier = "Event-Row-\(viewModel.eventID ?? 0)"
        }

        dataSource = UICollectionViewDiffableDataSource(collectionView: listView) { collectionView, indexPath, id in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: id)
        }
    }

    private func makeEmptyView() -> UIView {
        let imageView = UIImageView(image: UIImage(systemName: "line.3.horizontal.decrease.circle"))
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 48)
        imageView.tintColor = .secondaryLabel

        let label = UILabel()
        label.text = EventPackageStrings.noEventsForFilter
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .preferredFont(forTextStyle: .body)
        label.adjustsFontForContentSizeCategory = true

        let stackView = UIStackView(arrangedSubviews: [imageView, label])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        let container = UIView()
        container.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: container.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: container.layoutMarginsGuide.trailingAnchor)
        ])

        return container
    }

    // MARK: - UICollectionViewDelegate

    private func updateSelection() {
        let selectedItem = dataSource.snapshot().itemIdentifiers.first {
            selectedEventID != nil && eventsByID[$0]?.eventID == selectedEventID
        }
        let selectedIndexPath = selectedItem.flatMap { dataSource.indexPath(for: $0) }
        listView.indexPathsForSelectedItems?.filter { $0 != selectedIndexPath }.forEach {
            listView.deselectItem(at: $0, animated: false)
        }
        if let selectedIndexPath {
            listView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: [])
        }
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer { updateSelection() }

        guard let id = dataSource.itemIdentifier(for: indexPath), let eventID = eventsByID[id]?.eventID else { return }
        onSelectEvent?(eventID)
    }

}

#if DEBUG
#Preview("Day event list", traits: .fixedLayout(width: 360, height: 500)) {
    let cell = TimetableDayPageCell(frame: CGRect(x: 0, y: 0, width: 360, height: 500))
    cell.configure(
        events: [EventListItemViewModel(title: "Preview event", startDate: .now, location: "Festival stage")],
        isFilterActive: false,
        displayMode: .compact,
        onSelectEvent: { _ in }
    )
    return cell
}
#endif

#endif
