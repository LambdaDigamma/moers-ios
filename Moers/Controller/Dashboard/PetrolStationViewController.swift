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

class PetrolStationViewController: CardCollectionViewController {

    private let identifier = "petrolStation"
    private let locationManager: LocationManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    
    private var stations: [PetrolStation] = []
    private var averagePrice: Double = 0.0
    
    init(locationManager: LocationManagerProtocol,
         petrolManager: PetrolManagerProtocol,
         stations: [PetrolStation] = []) {
        
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
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.collectionView.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
    // MARK: - Private Methods
    
    private func reloadPetrolStationsForCurrentUserPosition() {
        
        locationManager.requestCurrentLocation()
        
        locationManager.location
            .debounce(interval: 2)
            .observeNext { location in
                self.loadPetrolStations(for: location.coordinate)
            }.dispose(in: bag)
        
    }
    
    private func loadPetrolStations(for coordinate: CLLocationCoordinate2D) {
        
        let preferredPetrolType = petrolManager.petrolType
        
        let petrolStations = petrolManager.getPetrolStations(coordinate: coordinate,
                                                             radius: 5,
                                                             sorting: .distance,
                                                             type: preferredPetrolType,
                                                             shouldReload: true)
        
        petrolStations.observeNext { stations in
            self.updateUI()
        }.dispose(in: bag)
        
    }
    
    private func updateUI() {
        
        self.sortStationsWithPriceAndOpenStatus()
        self.calculateAverageOfOpenStations()
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
        
    }
    
    private func sortStationsWithPriceAndOpenStatus() {
        
        self.stations = stations.sorted(by: { (p1, p2) -> Bool in
            p1.isOpen == p2.isOpen
        }).reversed()
        
        self.stations = stations.sorted { p1, p2 in
            if p1.isOpen == p2.isOpen {
                return (p1.price ?? 10) < (p2.price ?? 10)
            }
            return p1.isOpen && !p2.isOpen
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! PetrolStationCollectionViewCell
        
        cell.averagePrice = averagePrice
        cell.petrolStation = stations[indexPath.item]
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.stations.count
        
    }

}
