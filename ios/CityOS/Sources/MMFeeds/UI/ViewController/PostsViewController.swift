//
//  PostsViewController.swift
//  
//
//  Created by Lennart Fischer on 10.04.23.
//

import Core
import UIKit
import MMPages
import Combine
import FactoryKit

public class PostsViewController: UIViewController {
    
    private let viewModel: FeedPostListViewModel
    private let onShowPost: ((Post.ID) -> Void)
    private var cancellables = Set<AnyCancellable>()
    private var posts: [Post] = []
    private var didConfigureLayout = false
    private var refreshTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?

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

    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.accessibilityIdentifier = "NewsFeedRefreshControl"
        refreshControl.addTarget(self, action: #selector(refreshPosts(_:)), for: .valueChanged)
        return refreshControl
    }()

    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .large)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    private lazy var dataSource = makeDataSource()
    
    public convenience init(feedID: Feed.ID, onShowPost: @escaping ((Post.ID) -> Void)) {
        self.init(feedID: feedID, repository: Container.shared.postRepository(), onShowPost: onShowPost)
    }

    init(feedID: Feed.ID, repository: PostRepository, onShowPost: @escaping ((Post.ID) -> Void)) {
        self.viewModel = FeedPostListViewModel(
            feedID: feedID,
            postsPerLoad: 10,
            automaticallyLoadFirstPage: false,
            repository: repository
        )
        self.onShowPost = onShowPost
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupUI()
        
    }

    nonisolated deinit {
        refreshTask?.cancel()
        loadTask?.cancel()
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
        let viewModel = viewModel
        loadTask = Task {
            await viewModel.reload()
        }
        
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutMetricsIfNeeded()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .systemBackground
        collectionView.refreshControl = refreshControl
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
        viewModel.itemsPublisher
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

    @objc private func refreshPosts(_ sender: UIRefreshControl) {
        guard refreshTask == nil else {
            return
        }

        let viewModel = viewModel
        refreshTask = Task { [weak self, weak sender] in
            await viewModel.refresh()

            sender?.endRefreshing()
            self?.refreshTask = nil
        }
    }

    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Post.ID> {
        let cellRegistration = UICollectionView.CellRegistration<NewsPostCollectionViewCell, Post.ID> { [weak self] cell, _, postID in
            guard let self, let post = self.posts.first(where: { $0.id == postID }) else { return }

            cell.configure(with: post)
            cell.accessibilityIdentifier = "NewsPostCell-\(post.id)"
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

        return dataSource
    }

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Post.ID>()
        snapshot.appendSections([.posts])
        snapshot.appendItems(posts.map(\.id), toSection: .posts)
        let previousIDs = Set(dataSource.snapshot().itemIdentifiers)
        snapshot.reconfigureItems(snapshot.itemIdentifiers.filter { previousIDs.contains($0) })
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func buildLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 8, left: 24, bottom: 32, right: 24)
        layout.headerReferenceSize = .zero
        layout.sectionHeadersPinToVisibleBounds = false
        layout.estimatedItemSize = CGSize(width: 320, height: 360)
        return layout
    }

    private func updateLayoutMetricsIfNeeded() {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        let boundsWidth = collectionView.bounds.width
        guard boundsWidth > 0 else { return }

        let metrics = Self.layoutMetrics(for: boundsWidth)
        let sectionInset = UIEdgeInsets(top: 8, left: metrics.sideInset, bottom: 32, right: metrics.sideInset)
        let estimatedSize = CGSize(width: metrics.itemWidth, height: 360)

        let needsUpdate =
            !didConfigureLayout ||
            abs(layout.sectionInset.left - sectionInset.left) > 0.5 ||
            abs(layout.itemSize.width - estimatedSize.width) > 0.5

        guard needsUpdate else { return }

        didConfigureLayout = true
        layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = metrics.interItemSpacing
        layout.minimumLineSpacing = 24
        layout.headerReferenceSize = .zero
        layout.estimatedItemSize = estimatedSize
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        layout.invalidateLayout()
    }

    private static func layoutMetrics(for width: CGFloat) -> (columns: Int, readableWidth: CGFloat, sideInset: CGFloat, itemWidth: CGFloat, interItemSpacing: CGFloat) {
        let interItemSpacing: CGFloat = 24
        let horizontalPadding: CGFloat = 48
        let readableWidth = min(max(width - horizontalPadding, 0), 1_120)
        let sideInset = max((width - readableWidth) / 2, 24)
        let columns = readableWidth >= 700 ? 2 : 1
        let totalSpacing = CGFloat(columns - 1) * interItemSpacing
        let itemWidth = floor((readableWidth - totalSpacing) / CGFloat(columns))
        return (columns, readableWidth, sideInset, itemWidth, interItemSpacing)
    }

}

extension PostsViewController: UICollectionViewDelegate {

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let postID = dataSource.itemIdentifier(for: indexPath) else { return }
        onShowPost(postID)
    }
}
