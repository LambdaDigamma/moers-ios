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
import MediaLibraryKit
import Nuke

public class PostsViewController: UIViewController {
    
    private let viewModel: FeedPostListViewModel
    private let onShowPost: ((Post.ID) -> Void)
    private var cancellables = Set<AnyCancellable>()
    private var posts: [Post] = []
    private var didConfigureLayout = false

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

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateLayoutMetricsIfNeeded()
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
        let cellRegistration = UICollectionView.CellRegistration<NewsPostCollectionViewCell, Post.ID> { [weak self] cell, _, postID in
            guard let self, let post = self.posts.first(where: { $0.id == postID }) else { return }

            cell.configure(with: post)
            cell.accessibilityIdentifier = "NewsPostCell-\(post.id)"
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

    private func buildLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24
        layout.minimumInteritemSpacing = 24
        layout.sectionInset = UIEdgeInsets(top: 8, left: 24, bottom: 32, right: 24)
        layout.headerReferenceSize = CGSize(width: 1, height: 72)
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
        let headerSize = CGSize(width: metrics.readableWidth, height: 72)

        let needsUpdate =
            !didConfigureLayout ||
            abs(layout.sectionInset.left - sectionInset.left) > 0.5 ||
            abs(layout.itemSize.width - estimatedSize.width) > 0.5 ||
            abs(layout.headerReferenceSize.width - headerSize.width) > 0.5

        guard needsUpdate else { return }

        didConfigureLayout = true
        layout.sectionInset = sectionInset
        layout.minimumInteritemSpacing = metrics.interItemSpacing
        layout.minimumLineSpacing = 24
        layout.headerReferenceSize = headerSize
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

private final class NewsPostCollectionViewCell: UICollectionViewCell {

    private let cardView = UIView()
    private let mediaImageView = UIImageView()
    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private var mediaAspectConstraint: NSLayoutConstraint?
    private var imageTask: ImageTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
        imageTask = nil
        mediaImageView.image = nil
        mediaImageView.isHidden = false
        titleLabel.text = nil
        titleLabel.isHidden = false
        summaryLabel.text = nil
        summaryLabel.isHidden = false
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        attributes.size = CGSize(width: floor(layoutAttributes.size.width), height: ceil(fittedSize.height))
        return attributes
    }

    func configure(with post: Post) {
        cardView.backgroundColor = .secondarySystemBackground

        let isInstagram = post.extras?.type == "instagram"
        let title = post.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = post.summary.trimmingCharacters(in: .whitespacesAndNewlines)

        titleLabel.text = title
        titleLabel.isHidden = isInstagram || title.isEmpty

        summaryLabel.text = summary
        summaryLabel.numberOfLines = isInstagram ? 5 : 4
        summaryLabel.isHidden = summary.isEmpty

        configureMedia(for: post)
        accessibilityLabel = [titleLabel.text, summaryLabel.text].compactMap { $0 }.joined(separator: ", ")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.cornerCurve = .continuous
        cardView.clipsToBounds = true

        mediaImageView.translatesAutoresizingMaskIntoConstraints = false
        mediaImageView.backgroundColor = .secondarySystemFill
        mediaImageView.contentMode = .scaleAspectFill
        mediaImageView.clipsToBounds = true

        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.spacing = 6

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 3

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .preferredFont(forTextStyle: .footnote)
        summaryLabel.adjustsFontForContentSizeCategory = true
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 4

        contentView.addSubview(cardView)
        cardView.addSubview(mediaImageView)
        cardView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(summaryLabel)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            mediaImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            mediaImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            mediaImageView.topAnchor.constraint(equalTo: cardView.topAnchor),

            textStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: mediaImageView.bottomAnchor, constant: 14),
            textStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        updateAspectRatio(to: CGSize(width: 16, height: 9))
    }

    private func configureMedia(for post: Post) {
        let imageURL: URL?
        if let videoThumbnail = post.extras?.videoThumbnails?.thumbnails.last?.link {
            imageURL = videoThumbnail
        } else if let fullURL = post.headerMedia?.fullURL {
            imageURL = URL(string: fullURL)
        } else {
            imageURL = nil
        }

        if imageURL == nil {
            mediaImageView.isHidden = true
            updateAspectRatio(to: nil)
            mediaImageView.image = nil
            return
        }

        mediaImageView.isHidden = false
        updateAspectRatio(to: post.mediaAspectRatio())
        mediaImageView.image = nil

        guard let imageURL else { return }
        imageTask = ImagePipeline.shared.loadImage(with: imageURL) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let response):
                    self.mediaImageView.image = response.image
                case .failure:
                    self.mediaImageView.image = nil
                }
            }
        }
    }

    private func updateAspectRatio(to ratio: CGSize?) {
        mediaAspectConstraint?.isActive = false
        mediaAspectConstraint = nil

        guard let ratio, ratio.width > 0, ratio.height > 0 else { return }

        let multiplier = ratio.height / ratio.width
        let constraint = mediaImageView.heightAnchor.constraint(equalTo: mediaImageView.widthAnchor, multiplier: multiplier)
        constraint.priority = .required
        constraint.isActive = true
        mediaAspectConstraint = constraint
    }
}
