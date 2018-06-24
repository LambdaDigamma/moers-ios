//
//  PetrolStationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 06.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class PetrolStationViewController: CardCollectionViewController, PetrolManagerDelegate {

    private let identifier = "petrolStation"
    
    private var stations: [PetrolStation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Tankstellen"
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.setupConstraints()
        self.setupTheming()
        
        guard let coordinate = LocationManager.shared.lastLocation?.coordinate else { return }
        
        PetrolManager.shared.delegate = self
        PetrolManager.shared.sendRequest(coordiante: coordinate, radius: 10, sorting: .distance, type: .diesel)
        
    }
    
    func didReceivePetrolStations(stations: [PetrolStation]) {
        
        self.stations = stations
        
        collectionView.reloadData()
        
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
        
        cell.backgroundColor = UIColor.white
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 4
        
    }

}
