//
//  MapViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import UIKit
import Core
import MMEvents
import SwiftUI
import Factory
import Combine
import Pulley
import GRDB

public enum DrawerFestivalMapSection {
    case main
    case booths
}

extension UITextField {
    
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(
            for: UITextField.textDidChangeNotification,
            object: self
        )
        .compactMap { ($0.object as? UITextField)?.text }
        .eraseToAnyPublisher()
    }
    
}

public class DrawerFestivalMapViewController: UIViewController, UICollectionViewDelegate, UISearchBarDelegate {
    
    @LazyInjected(\.placeRepository) var placeRepository
    
    var dataSource: UICollectionViewDiffableDataSource<DrawerFestivalMapSection, DrawerItem>!
    var cancellables = Set<AnyCancellable>()
    
    private var playersCancellable: AnyCancellable?
    
    // MARK: - Data Sources
    
    var places: [Place] = []
    var booths: [DorfFeature] = []
    
    var filteredBooths: [DorfFeature] = []
    
    // MARK: End Data Sources -
    
    
    
    private lazy var searchField: UISearchBar = {
        let searchField = UISearchBar()
        searchField.translatesAutoresizingMaskIntoConstraints = false
        return searchField
    }()
    
    private lazy var gripper: GripperView = {
        let gripper = GripperView()
        gripper.translatesAutoresizingMaskIntoConstraints = false
        return gripper
    }()
    
    private lazy var collectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: setupCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    // MARK: - Data -
    
    private let viewModel: FestivalMapViewModel
    
    public var coordinator: MapCoordinator?
    
    init(viewModel: FestivalMapViewModel) {
        self.viewModel = FestivalMapViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupCollectionViewDataSource()
        self.setupLoading()
        self.loadBoothsFromDiskAndPresent()
        
        self.pulleyViewController?.delegate = self
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(receiveUpdateGeoData), name: .updateFestivalGeoData, object: nil)
        
        self.loadBoothsFromDiskAndPresent()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .updateFestivalGeoData, object: nil)
    }
    
    // MARK: - UI -
    
    private func setupUI() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.view.addSubview(searchField)
        self.view.addSubview(gripper)
        self.view.addSubview(collectionView)
        self.collectionView.delegate = self
        
        self.searchField.tintColor = UIColor.systemYellow
        self.searchField.placeholder = "Search for venue…"
        self.searchField.searchBarStyle = .minimal
        self.searchField.isTranslucent = true
        self.searchField.enablesReturnKeyAutomatically = true
        self.searchField.delegate = self
        self.searchField.textField?.returnKeyType = .search
        
        self.collectionView.contentInset = .init(top: 0, left: 0, bottom: 100, right: 0)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            gripper.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 6),
            gripper.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
//            searchField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            searchField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 6),
            searchField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func reloadDataSource() {
        
        var snapshot = NSDiffableDataSourceSnapshot<DrawerFestivalMapSection, DrawerItem>()
        
        snapshot.appendSections([.main, .booths])
        
        snapshot.appendItems(places.map { (place: Place) in
            return DrawerItem.venue(FestivalPlaceRowUi(
                id: place.id,
                name: place.name,
                description: "\(place.streetName ?? "") \(place.streetNumber ?? "")",
                timeInformation: nil
            ))
        }, toSection: .main)
        
        snapshot.appendItems(filteredBooths.map {
            .booth($0)
        }, toSection: .booths)
        
        self.dataSource?.apply(snapshot)
        
    }
    
    // MARK: - Data -
    
    private func setupLoading() {
        
        searchField.textField?.textPublisher
            .sink { text in
                self.observePlaces()
                self.filterBooths(text: text)
            }
            .store(in: &cancellables)
        
        self.observePlaces()
        
    }
    
    private func observePlaces() {
        
        playersCancellable = placeRepository.changeObserver()
            .map({
                $0
                    .filter {
                        if let text = self.searchField.text, text.isNotEmptyOrWhitespace {
                            return $0.name.contains(text)
                        }
                        return true
                    }
            })
            .sink { (completion: Subscribers.Completion<Error>) in
                
            } receiveValue: { (places: [Place]) in
                
                print(places)
                
                self.places = places
                self.reloadDataSource()
                                
            }
        
    }
    
    private func filterBooths(text: String) {
        
        let sanitizeText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if sanitizeText.isNotEmptyOrWhitespace {
            filteredBooths = booths.filter { ($0.properties.name ?? "").contains(text) }
        } else {
            filteredBooths = booths
        }
        
        
        reloadDataSource()
        
    }
    
    private func loadBoothsFromDiskAndPresent() {
        
        do {
            
            guard let directory = LocalFGDStore.directory() else { return }
            
            let festivalGeoData = try FGDArchiveDecoder().decode(directory)
            
            self.booths = festivalGeoData.dorf
            self.filterBooths(text: "")
            
        } catch {
            print(error)
        }
        
    }
    
    @objc private func receiveUpdateGeoData() {
        
        self.loadBoothsFromDiskAndPresent()
        
    }
    
    // MARK: - Actions -
    
    private func showPlace(placeID: Place.ID) {
        
        guard let coordinator else {
            return print("WARNING: Coordinator not set.")
        }
        
        coordinator.showPlaceDetail(placeID: placeID)
        
    }
    
    private func showBooth(feature: DorfFeature) {
        
        guard let drawer = self.parent as? MapCoordinatorViewController else { return }
        
        drawer.setDrawerPosition(position: .collapsed, animated: true)
        drawer.mapViewController.focus(feature: feature)
        
    }
    
    // MARK: - List -
    
    func setupCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment -> NSCollectionLayoutSection? in
            
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
            headerElement.zIndex = 100000
            
            let section = NSCollectionLayoutSection.list(
                using: configuration,
                layoutEnvironment: environment
            )
            section.boundarySupplementaryItems = [headerElement]
            
            let separatorConfiguration = UIListSeparatorConfiguration(listAppearance: .plain)
            
            configuration.separatorConfiguration = separatorConfiguration
            
            return section
            
        }
        return layout
    }
    
    func setupCollectionViewDataSource() {
        
        let venueCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, FestivalPlaceRowUi> { cell, indexPath, item in
            
            cell.contentConfiguration = UIHostingConfiguration {
                
                FestivalPlaceRow(place: item)
                
            }
            
            cell.backgroundConfiguration = .listPlainCell()
            
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { [unowned self] (headerView, elementKind, indexPath) in
            
            // Obtain header item using index path
            let headerItem = self.dataSource!.snapshot().sectionIdentifiers[indexPath.section]
            
            // Configure header view content based on headerItem
            var configuration = headerView.defaultContentConfiguration()
            
            switch headerItem {
                case .main:
                    configuration.text = "Spielorte"
                case .booths:
                    configuration.text = "Stände"
                    
            }
            
            // Apply the configuration to header view
            headerView.contentConfiguration = configuration
            
        }
        
        let boothCellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, DorfFeature> { cell, indexPath, item in
            
            cell.contentConfiguration = UIHostingConfiguration {
                
                BoothRow(
                    booth: BoothRowUi(
                        name: item.properties.name ?? "",
                        description: item.properties.description ?? "",
                        isFood: item.properties.isFood
                    )
                )
                
            }
            
            cell.backgroundConfiguration = .listPlainCell()
            
        }
        
        /// Create a datasource and connect it to  collection view `collectionView`
        dataSource = UICollectionViewDiffableDataSource<DrawerFestivalMapSection, DrawerItem>(
            collectionView: collectionView
        ) { (collectionView: UICollectionView, indexPath: IndexPath, item: DrawerItem) -> UICollectionViewCell? in
            
            switch item {
                case .venue(let festivalPlaceRowUi):
                    
                    let cell = collectionView.dequeueConfiguredReusableCell(
                        using: venueCellRegistration,
                        for: indexPath,
                        item: festivalPlaceRowUi
                    )
                    
                    return cell
                    
                case .booth(let dorfFeature):
                    
                    let cell = collectionView.dequeueConfiguredReusableCell(
                        using: boothCellRegistration,
                        for: indexPath,
                        item: dorfFeature
                    )
                    
                    return cell
                    
            }
            
        }
        
        dataSource!.supplementaryViewProvider = { [unowned self]
            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            
            if elementKind == UICollectionView.elementKindSectionHeader {
                
                // Dequeue header view
                return self.collectionView.dequeueConfiguredReusableSupplementary(
                    using: headerRegistration,
                    for: indexPath
                )
                
            }
            
            return nil
            
        }
        
    }
    
    // MARK: - UICollectionViewDelegate -
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        
        switch item {
            case .venue(let venue):
                self.showPlace(placeID: venue.id)
               
            case .booth(let booth):
                self.showBooth(feature: booth)
        }
        
        collectionView.deselectItem(at: indexPath, animated: true)
        
    }
    
    public func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let viewController = self.parent as? PulleyViewController {
            viewController.setDrawerPosition(position: .open, animated: true)
        }
        return true
    }
    
    
    
}

extension DrawerFestivalMapViewController: PulleyDelegate {
    
    public func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat) {
        
        searchField.resignFirstResponder()
        searchField.textField?.resignFirstResponder()
        
    }
    
}
