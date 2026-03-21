//
//  NewMapDrawerViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 20.03.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import UIKit
import Core
import MMEvents
import SwiftUI
import Factory
import Combine

protocol NewMapDrawerDelegate: AnyObject {
    func drawerDidSelectBooth(_ booth: DorfFeature)
    func drawerDidSelectVenue(_ venue: FestivalPlaceRowUi)
}

class NewMapDrawerViewController: UIViewController {
    
    // MARK: - Properties
    
    weak var delegate: NewMapDrawerDelegate?
    weak var mapViewController: NewMapViewController?
    
    @LazyInjected(\.placeRepository) var placeRepository
    
    private var cancellables = Set<AnyCancellable>()
    
    var dataSource: UICollectionViewDiffableDataSource<DrawerFestivalMapSection, DrawerItem>!
    
    private var places: [Place] = []
    private var booths: [DorfFeature] = []
    private var filteredBooths: [DorfFeature] = []
    
    // MARK: - UI Elements
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.placeholder = String(localized: "Search for venue…")
        searchBar.searchBarStyle = .minimal
        searchBar.isTranslucent = true
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
        setupDataSource()
        loadData()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        
        if #available(iOS 26.0, *) {
            self.view.backgroundColor = .clear
        } else {
            self.view.backgroundColor = UIColor.systemBackground
        }
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: tabBarController?.tabBar.bounds.height ?? 50, right: 0)
        
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 4),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -4),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    public func setCollectionViewScrollInteraction(isEnabled: Bool) {
        collectionView.isScrollEnabled = isEnabled
    }
    
    // MARK: - Data
    
    private func loadData() {
        
        loadBooths()
        observePlaces()
    }
    
    private func loadBooths() {
        
        do {
            guard let directory = LocalFGDStore.directory() else { return }
            
            let festivalGeoData = try FGDArchiveDecoder().decode(directory)
            
            self.booths = festivalGeoData.dorf
            self.filteredBooths = booths
            reloadDataSource()
            
        } catch {
            print("Error loading booths: \(error)")
        }
    }
    
    private func observePlaces() {
        
        placeRepository.changeObserver()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                
            } receiveValue: { [weak self] places in
                guard let self = self else { return }
                
                let searchText = self.searchBar.text ?? ""
                
                self.places = places.filter { place in
                    if searchText.isEmpty {
                        return true
                    }
                    return place.name.localizedCaseInsensitiveContains(searchText)
                }
                
                self.reloadDataSource()
            }
            .store(in: &cancellables)
    }
    
    private func reloadDataSource() {
        
        var snapshot = NSDiffableDataSourceSnapshot<DrawerFestivalMapSection, DrawerItem>()
        
        snapshot.appendSections([.main, .booths])
        
        snapshot.appendItems(places.map { place in
            .venue(FestivalPlaceRowUi(
                id: place.id,
                name: place.name,
                description: "\(place.streetName ?? "") \(place.streetNumber ?? "")",
                timeInformation: nil
            ))
        }, toSection: .main)
        
        snapshot.appendItems(filteredBooths.map { .booth($0) }, toSection: .booths)
        
        dataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    private func filterBooths(with searchText: String) {
        
        if searchText.isEmpty {
            filteredBooths = booths
        } else {
            filteredBooths = booths.filter { ($0.properties.name ?? "").localizedCaseInsensitiveContains(searchText) }
        }
        
        reloadDataSource()
    }
    
    // MARK: - Collection View
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            
            var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
            configuration.headerMode = .supplementary
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
            
            let headerElement = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            
            headerElement.pinToVisibleBounds = true
            headerElement.extendsBoundary = true
            
            let section = NSCollectionLayoutSection.list(using: configuration, layoutEnvironment: environment)
            section.boundarySupplementaryItems = [headerElement]
            
            return section
        }
    }
    
    private func setupDataSource() {
        
        let venueCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, FestivalPlaceRowUi> { cell, indexPath, item in
            
            cell.contentConfiguration = UIHostingConfiguration {
                FestivalPlaceRow(place: item)
            }
            cell.backgroundConfiguration = .listPlainCell()
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [weak self] headerView, elementKind, indexPath in
            
            guard let section = self?.dataSource?.snapshot().sectionIdentifiers[indexPath.section] else { return }
            
            var configuration = headerView.defaultContentConfiguration()
            
            switch section {
            case .main:
                configuration.text = "Spielorte"
            case .booths:
                configuration.text = "Stände"
            }
            
            headerView.contentConfiguration = configuration
        }
        
        let boothCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, DorfFeature> { cell, indexPath, item in
            
            cell.contentConfiguration = UIHostingConfiguration {
                BoothRow(booth: BoothRowUi(
                    name: item.properties.name ?? "",
                    description: item.properties.description ?? "",
                    isFood: item.properties.isFood
                ))
            }
            cell.backgroundConfiguration = .listPlainCell()
        }
        
        dataSource = UICollectionViewDiffableDataSource<DrawerFestivalMapSection, DrawerItem>(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            
            switch item {
            case .venue(let venue):
                return collectionView.dequeueConfiguredReusableCell(using: venueCellRegistration, for: indexPath, item: venue)
                
            case .booth(let booth):
                return collectionView.dequeueConfiguredReusableCell(using: boothCellRegistration, for: indexPath, item: booth)
            }
        }
        
        dataSource?.supplementaryViewProvider = { collectionView, elementKind, indexPath in
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                return collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration,
                    for: indexPath
                )
            }
            
            return nil
        }
    }
    
}

// MARK: - UICollectionViewDelegate

extension NewMapDrawerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
        case .venue(let venue):
            delegate?.drawerDidSelectVenue(venue)
            
        case .booth(let booth):
            delegate?.drawerDidSelectBooth(booth)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: - UISearchBarDelegate

extension NewMapDrawerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filterBooths(with: searchText)
        observePlaces()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        searchBar.resignFirstResponder()
    }
}
