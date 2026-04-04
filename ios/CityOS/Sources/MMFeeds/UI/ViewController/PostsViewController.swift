//
//  PostsViewController.swift
//  
//
//  Created by Lennart Fischer on 10.04.23.
//

import Core
import UIKit
import MMPages
import MMFeeds
import Combine
import SwiftUI

public class PostsViewController: UIViewController {
    
    private let viewModel: FeedPostListViewModel
    private let onShowPost: ((Post.ID) -> Void)
    private var cancellables = Set<AnyCancellable>()
    private var posts: [Post] = []

    private enum Section: Int, CaseIterable {
        case posts
    }

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: buildLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    private lazy var dataSource = makeDataSource()
    
    public init(feedID: Feed.ID, onShowPost: @escaping ((Post.ID) -> Void)) {
        
        self.viewModel = FeedPostListViewModel(
            feedID: 3,
            postsPerLoad: 10,
            automaticallyLoadFirstPage: false
        )
        self.onShowPost = onShowPost
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = [.all]
        self.extendedLayoutIncludesOpaqueBars = true
        self.navigationItem.largeTitleDisplayMode = .never

        setupObservers()
        Task {
            await viewModel.reload()
        }
        
    }
    
    private func setupUI() {
        
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(activityIndicatorView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
    }

    private func setupObservers() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] resource in
                guard let self else { return }

                switch resource {
                case .loading:
                    activityIndicatorView.startAnimating()
                case .success(let posts):
                    activityIndicatorView.stopAnimating()
                    self.posts = posts
                    applySnapshot()
                case .error:
                    activityIndicatorView.stopAnimating()
                    self.posts = []
                    applySnapshot()
                }
            }
            .store(in: &cancellables)
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Post.ID> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Post.ID> { [weak self] cell, _, postID in
            guard let self, let post = self.posts.first(where: { $0.id == postID }) else { return }

            cell.contentConfiguration = UIHostingConfiguration {
                Group {
                    if post.extras?.type == "instagram" {
                        InstagramPostView(post: post, showPost: { self.onShowPost($0.id) })
                    } else {
                        BigNewsFeedView(post: post, showPost: { self.onShowPost($0.id) })
                    }
                }
            }
            .margins(.all, 0)

            cell.backgroundConfiguration = .clear()
        }

        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionReusableView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { supplementaryView, _, _ in
            supplementaryView.subviews.forEach { $0.removeFromSuperview() }

            let titleLabel = UILabel()
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .largeTitle).pointSize)
            titleLabel.adjustsFontForContentSizeCategory = true
            titleLabel.textColor = .label
            titleLabel.text = String(localized: "News", bundle: .main)

            supplementaryView.addSubview(titleLabel)

            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: supplementaryView.leadingAnchor),
                titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: supplementaryView.trailingAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: supplementaryView.bottomAnchor, constant: -8),
                titleLabel.topAnchor.constraint(equalTo: supplementaryView.topAnchor, constant: 8)
            ])
        }

        let dataSource = UICollectionViewDiffableDataSource<Section, Post.ID>(
            collectionView: collectionView
        ) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: itemIdentifier
            )
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            return collectionView.dequeueConfiguredReusableSupplementary(
                using: headerRegistration,
                for: indexPath
            )
        }

        return dataSource
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post.ID>()
        snapshot.appendSections([.posts])
        snapshot.appendItems(posts.map(\.id), toSection: .posts)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func buildLayout() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, environment -> NSCollectionLayoutSection? in
            let itemsPerRow: Int
            let width = environment.container.effectiveContentSize.width

            if width > 1_000 {
                itemsPerRow = 2
            } else if width > 620 {
                itemsPerRow = 2
            } else {
                itemsPerRow = 1
            }

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0 / CGFloat(itemsPerRow)),
                    heightDimension: .estimated(360)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(360)
                ),
                subitem: item,
                count: itemsPerRow
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 24

            let readableWidth = min(max(width - 48, 0), 1_120)
            let sideInset = max((width - readableWidth) / 2, 24)
            section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: sideInset, bottom: 32, trailing: sideInset)

            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(72)
                ),
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}

extension PostsViewController: UICollectionViewDelegate {}
