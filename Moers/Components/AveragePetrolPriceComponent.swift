//
//  AveragePetrolPriceComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 29.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation

class AveragePetrolPriceComponent: BaseComponent, LocationManagerDelegate, PetrolManagerDelegate {

    let locationManager = LocationManager()
    
    lazy var averagePetrolCardView: DashboardAveragePetrolPriceCardView = {
        
        let cardView = DashboardAveragePetrolPriceCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    override init(viewController: UIViewController) {
        super.init(viewController: viewController)
        
        self.register(view: averagePetrolCardView)
        
        LocationManager.shared.delegate = self
        PetrolManager.shared.delegate = self
        
        self.update()
        
    }
    
    override func update() {
        
        self.locationManager.delegate = self
        
        if self.locationManager.authorizationStatus != .denied {
            self.locationManager.requestCurrentLocation()
            self.averagePetrolCardView.dismissError()
            self.averagePetrolCardView.startLoading()
        } else {
            self.averagePetrolCardView.showError(withTitle: "Berechtigung fehlt", message: "Die App darf nicht auf deinen aktuellen Standort zugreifen, um aktuelle Spritpreise zu berechnen.")
        }
        
    }
    
    override func invalidate() {
        
        self.locationManager.stopMonitoring()
        self.averagePetrolCardView.stopLoading()
        
    }
    
    // MARK: - LocationManagerDelegate
    
    func didReceiveCurrentLocation(location: CLLocation) {
        
        GeocodingManager.shared.city(from: location) { (city) in
            
            self.averagePetrolCardView.locationLabel.text = city
            
        }
        
        GeocodingManager.shared.countryCode(from: location) { (countryCode) in
            
            if countryCode != "DE" {
                
                self.averagePetrolCardView.showError(withTitle: "Spritinformationen", message: "Nur in Deutschland verfügbar")
                
            } else {
                
                PetrolManager.shared.delegate = self
                PetrolManager.shared.sendRequest(coordiante: location.coordinate, radius: 10.0, sorting: .distance, type: .diesel)
                
            }
            
        }
        
    }
    
    func didFailWithError(error: Error) {
        
        
        
    }
    
    // MARK: - PetrolManagerDelegate
    
    func didReceivePetrolStations(stations: [PetrolStation]) {
        
        DispatchQueue.main.async {
            
            let openStations = stations.filter { $0.isOpen }
            
            self.averagePetrolCardView.stopLoading()
            self.averagePetrolCardView.numberOfStations = openStations.count
            
            let sum = openStations.reduce(0) { (result, item) in
                
                return result + (item.price ?? 0)
                
            }
            
            let averagePrice = sum / Double(openStations.count)
            
            self.averagePetrolCardView.price = averagePrice
            
        }
        
    }
    
    
}