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
import Resolver

public class FeedViewController: UIViewController {

    @LazyInjected var feedService: FeedService
    
    private lazy var collectionView: UICollectionView = {
        return ViewFactory.collectionView(layout: buildCollectionViewLayout())
    }()
    
    private var viewModel: FeedPostListViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Init -
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = FeedPostListViewModel(feedID: 3, service: feedService)
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
//                var snapshot = NSDiffableDataSourceSnapshot<Section, PostViewModel>()
//                snapshot.appendSections(Section.allCases)
//                snapshot.appendItems(posts.map { PostViewModel(model: $0) }, toSection: .all)
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
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<Section, LegacyPostViewModel> {
        let cellRegistration = makeVideoCellRegistration()
        
        return UICollectionViewDiffableDataSource<Section, LegacyPostViewModel>(
            collectionView: collectionView,
            cellProvider: { view, indexPath, item in
                view.dequeueConfiguredReusableCell(
                    using: cellRegistration,
                    for: indexPath,
                    item: item
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
    
    private func makeVideoCellRegistration() -> UICollectionView.CellRegistration<PostVideoCollectionViewCell, LegacyPostViewModel> {
        UICollectionView.CellRegistration { (cell, indexPath, post: LegacyPostViewModel) in
            
//            cell.post = post.emodel
            
//            guard let
            
//            post.model.extras
            
            if let player = post.player {
                player.outputs.forEach { player.remove($0) }
            }
            
//            post.player?.outputs.forEach { post. }
            
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
