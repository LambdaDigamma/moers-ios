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
final class TimetableDayPageCell: UICollectionViewCell, UICollectionViewDelegate {

    private(set) var listView: UICollectionView!

    private var dataSource: UICollectionViewDiffableDataSource<Int, UUID>!
    private var eventsByID: [UUID: EventListItemViewModel] = [:]
    private var displayMode: DailyEventsDisplayMode = .compact
    private var onSelectEvent: ((Event.ID) -> Void)?
    private var onRefresh: (() async -> Void)?

    private lazy var emptyView = makeEmptyView()

    nonisolated deinit {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupListView()
        setupDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        day: TimetableDay?,
        isFilterActive: Bool,
        displayMode: DailyEventsDisplayMode,
        onRefresh: @escaping () async -> Void,
        onSelectEvent: @escaping (Event.ID) -> Void
    ) {
        let modeChanged = self.displayMode != displayMode
        self.displayMode = displayMode
        self.onRefresh = onRefresh
        self.onSelectEvent = onSelectEvent

        let events = day?.events ?? []
        eventsByID = Dictionary(events.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })

        var snapshot = NSDiffableDataSourceSnapshot<Int, UUID>()
        snapshot.appendSections([0])
        snapshot.appendItems(events.map(\.id))
        if modeChanged {
            snapshot.reconfigureItems(events.map(\.id))
            listView.collectionViewLayout.invalidateLayout()
        }
        dataSource.apply(snapshot, animatingDifferences: false)

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
        listView.refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction { [weak self] action in
            guard let refreshControl = action.sender as? UIRefreshControl else { return }
            Task { @MainActor in
                await self?.onRefresh?()
                refreshControl.endRefreshing()
            }
        })

        contentView.addSubview(listView)
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
                }
            }
            .margins(.horizontal, isImages ? 16 : 20)
            .margins(.vertical, isImages ? 8 : 12)

            cell.backgroundConfiguration = isImages ? .clear() : .listPlainCell()
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        guard let id = dataSource.itemIdentifier(for: indexPath), let eventID = eventsByID[id]?.eventID else { return }
        onSelectEvent?(eventID)
    }

}

#endif
