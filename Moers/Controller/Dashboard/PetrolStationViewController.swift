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
    
    private var stations: [PetrolStation] = []
    private var averagePrice: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.loadData()
        
    }
    
    // MARK: - Private Methods
    
    private func loadData() {
        
        self.stations = PetrolManager.shared.cachedStations ?? []
        
        self.stations = stations.sorted { p1, p2 in
            if p1.isOpen == p2.isOpen {
                return (p1.price ?? 10) < (p2.price ?? 10)
            }
            return p1.isOpen && !p2.isOpen
        }
        
        let openStations = stations.filter { $0.isOpen && $0.price != nil }
        
        let sum = openStations.reduce(0) { (result, item) in
            
            return result + (item.price ?? 0)
            
        }
        
        self.averagePrice = sum / Double(openStations.count)
        
    }
    
    private func reloadData() {
        
        OperationQueue.main.addOperation {
            
            LocationManager.shared.getCurrentLocation { (location, error) in
                
                guard let coordinate = location?.coordinate else { return }
                
                PetrolManager.shared.delegate = self
                PetrolManager.shared.sendRequest(coordiante: coordinate, radius: 5, sorting: .distance, type: PetrolManager.shared.petrolType)
                
            }
            
        }
        
    }
    
    private func setupUI() {
        
        self.title = String.localized("PetrolStationsTitle")
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(PetrolStationCollectionViewCell.self, forCellWithReuseIdentifier: identifier)
        
    }
    
    private func setupConstraints() {
        
        
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.collectionView.backgroundColor = theme.backgroundColor
            
        }
        
    }
    
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

extension PetrolStationViewController: PetrolManagerDelegate {
    
    func petrolManager(_ manager: PetrolManager, didReceivePetrolStations stations: [PetrolStation]) {
        
        self.stations = stations.sorted(by: { (p1, p2) -> Bool in
            p1.isOpen == p2.isOpen
        }).reversed()
        
        print(stations)
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
            
        }
        
    }
    
}
