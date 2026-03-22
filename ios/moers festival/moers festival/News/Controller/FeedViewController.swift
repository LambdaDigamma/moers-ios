//
//  FeedViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 21.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import Combine
import MMFeeds
import Factory

public class FeedViewController: UIViewController {

    @LazyInjected(\.feedService) var feedService

    private lazy var collectionView: UICollectionView = {
        return ViewFactory.collectionView(layout: buildCollectionViewLayout())
    }()

    private var viewModel: FeedPostListViewModel!
    private var cancellables = Set<AnyCancellable>()
    private var viewModelsByID: [UUID: LegacyPostViewModel] = [:]

    private lazy var dataSource = makeDataSource()

    // MARK: - Init -

    public init() {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = FeedPostListViewModel(feedID: 3)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIViewController Lifecycle -

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()

        // Do any additional setup after loading the view.
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.loadData()
        self.setupLoadingObservers()

    }

    // MARK: - Setup UI

    private func setupUI() {

        self.view.addSubview(collectionView)

    }

    private func setupConstraints() {

        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)

    }

    // MARK: - Load Data

    private func loadData() {

//        viewModel.loadCurrentFeed()
//        viewModel.loadNextPosts()

    }

    private func setupLoadingObservers() {

//        viewModel.$items.sink { (posts: [Post]) in
//
//            if !posts.isEmpty {
//                let viewModels = posts.map { LegacyPostViewModel(model: $0) }
//                self.viewModelsByID = Dictionary(uniqueKeysWithValues: viewModels.map { ($0.id, $0) })
//
//                var snapshot = NSDiffableDataSourceSnapshot<Section, UUID>()
//                snapshot.appendSections(Section.allCases)
//                snapshot.appendItems(viewModels.map(\.id), toSection: .all)
//
//                DispatchQueue.main.async {
//                    print("Applying Snapshot")
//                    self.dataSource.apply(snapshot)
//                }
//            }
//
//
//        }.store(in: &cancellables)

    }

    // MARK: - Collection View

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, UUID> {
        let cellRegistration = makeVideoCellRegistration()

        return UICollectionViewDiffableDataSource<Section, UUID>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, itemIdentifier in
                view.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: itemIdentifier
                )
            }
        )
    }

    private func buildCollectionViewLayout() -> UICollectionViewCompositionalLayout {

        return UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in

            guard let sectionKind = Section(rawValue: sectionIndex) else { return nil }

            if sectionKind == .all {

                let itemsPerRow = environment.traitCollection.horizontalSizeClass == .compact ? 1 : 2
                let fraction: CGFloat = 1 / CGFloat(itemsPerRow)
                let inset: CGFloat = 0

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(fraction),
                    heightDimension: .estimated(300)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: inset, leading: inset, bottom: inset, trailing: inset)

                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemsPerRow)
                group.interItemSpacing = .fixed(16)

                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 16
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)

//                let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(90))
//                let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
//                section.boundarySupplementaryItems = [headerItem]

                return section

            } else {
                return nil
            }

        }

    }

    private func makeVideoCellRegistration() -> UICollectionView.CellRegistration<PostVideoCollectionViewCell, UUID> {
        UICollectionView.CellRegistration { [weak self] (cell, _, itemIdentifier: UUID) in

            guard let post = self?.viewModelsByID[itemIdentifier] else {
                return
            }

            if let player = post.player {
                player.outputs.forEach { player.remove($0) }
            }

            let contentConfiguration = PostVideoContentConfiguration(
                name: post.model.title,
                description: post.model.summary,
                video: VimeoVideoThumbnailDescription(),
                playerItem: post.player
            )

            cell.contentConfiguration = contentConfiguration

//            let contentConfiguration = CalendarContentConfiguration(
//                name: calendar.title,
//                description: calendar.description,
//                infoBoxColor: UIColor(hex: calendar.infoBoxColor) ?? UIColor.clear,
//                image: UIImage(named: calendar.image) ?? UIImage())
//
//            cell.contentConfiguration = contentConfiguration
        }
    }

}

extension FeedViewController {

    enum Section: Int, CaseIterable {
        case all
    }

}
