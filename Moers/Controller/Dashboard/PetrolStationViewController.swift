//
//  PetrolStationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import CoreLocation
import MMAPI
import MMUI
import Combine

class PetrolStationViewController: CardCollectionViewController {

    private let identifier = "petrolStation"
    private let locationManager: LocationManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    
    private var stations: [PetrolStation] = []
    private var averagePrice: Double = 0.0
    private var cancellables = Set<AnyCancellable>()
    
    init(
        locationManager: LocationManagerProtocol,
        petrolManager: PetrolManagerProtocol,
        stations: [PetrolStation] = []
    ) {
        
        self.locationManager = locationManager
        self.petrolManager = petrolManager
        self.stations = stations
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupTheming()
        self.updateUI()
        
    }
    
    private func setupUI() {
        
        self.title = String.localized("PetrolStationsTitle")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(PetrolStationCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    // MARK: - Private Methods
    
    private func reloadPetrolStationsForCurrentUserPosition() {
        
        locationManager.requestCurrentLocation()
        
        locationManager.location
            .debounce(for: 2, scheduler: RunLoop.main)
            .sink(receiveCompletion: { (_: Subscribers.Completion<Error>) in
                
            }, receiveValue: { location in
                self.loadPetrolStations(for: location.coordinate)
            })
            .store(in: &cancellables)
            
    }
    
    private func loadPetrolStations(for coordinate: CLLocationCoordinate2D) {
        
        let preferredPetrolType = petrolManager.petrolType
        
        let petrolStations = petrolManager.getPetrolStations(coordinate: coordinate,
                                                             radius: 5,
                                                             sorting: .distance,
                                                             type: preferredPetrolType,
                                                             shouldReload: true)
        
        petrolStations.sink { _ in
            
        } receiveValue: { _ in
            self.updateUI()
        }
        .store(in: &cancellables)
        
    }
    
    private func updateUI() {
        
        self.sortStationsWithPriceAndOpenStatus()
        self.calculateAverageOfOpenStations()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    private func sortStationsWithPriceAndOpenStatus() {
        
        self.stations = stations.sorted(by: { (station1, station2) -> Bool in
            station1.isOpen == station2.isOpen
        }).reversed()
        
        self.stations = stations.sorted { station1, station2 in
            if station1.isOpen == station2.isOpen {
                return (station1.price ?? 10) < (station2.price ?? 10)
            }
            return station1.isOpen && !station2.isOpen
        }
        
    }
    
    private func calculateAverageOfOpenStations() {
        
        let openStations = stations.filter { $0.isOpen && $0.price != nil }
        
        let sum = openStations.reduce(0) { (result, item) in
            return result + (item.price ?? 0)
        }
        
        self.averagePrice = sum / Double(openStations.count)
        
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PetrolStationCollectionViewCell
        
        cell.averagePrice = averagePrice
        cell.petrolStation = stations[indexPath.item]
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.stations.count
        
    }

}
