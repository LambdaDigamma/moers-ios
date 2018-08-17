//
//  AveragePetrolPriceComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 29.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation

class AveragePetrolPriceComponent: BaseComponent, LocationManagerDelegate, PetrolManagerDelegate, UIViewControllerPreviewingDelegate {

    let locationManager = LocationManager()
    private var place: String = ""
    
    lazy var averagePetrolCardView: DashboardAveragePetrolPriceCardView = {
        
        let cardView = DashboardAveragePetrolPriceCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    override init(viewController: UIViewController) {
        super.init(viewController: viewController)
        
        self.register(view: averagePetrolCardView)
        
        self.viewController?.registerForPreviewing(with: self, sourceView: averagePetrolCardView)
        
        LocationManager.shared.delegate = self
        PetrolManager.shared.delegate = self
        
        self.averagePetrolCardView.isUserInteractionEnabled = true
        self.averagePetrolCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPetrolStationViewController)))
        
        self.update()
        
    }
    
    override func update() {
        
        self.locationManager.delegate = self
        self.averagePetrolCardView.petrolType = PetrolManager.shared.petrolType
        
        if self.locationManager.authorizationStatus != .denied {
            self.locationManager.requestCurrentLocation()
            self.averagePetrolCardView.dismissError()
            self.averagePetrolCardView.startLoading()
        } else {
            self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorPermissionTitle"), message: String.localized("PetrolErrorPermissionMessage"))
        }
        
    }
    
    override func invalidate() {
        
        self.locationManager.stopMonitoring()
        self.averagePetrolCardView.stopLoading()
        
    }
    
    private func petrolStationVC() -> PetrolStationViewController {
        
        AnalyticsManager.shared.logOpenedPetrolPrices(for: place)
        
        let petrolStationViewController = PetrolStationViewController()
        
        return petrolStationViewController
        
    }
    
    @objc private func showPetrolStationViewController() {
        
        let petrolStationViewController = petrolStationVC()
        
        viewController?.navigationController?.pushViewController(petrolStationViewController, animated: true)

    }
    
    // MARK: - LocationManagerDelegate
    
    func didReceiveCurrentLocation(location: CLLocation) {
        
        GeocodingManager.shared.city(from: location) { (city) in
            
            self.place = city ?? ""
            self.averagePetrolCardView.locationLabel.text = city
            
        }
        
        GeocodingManager.shared.countryCode(from: location) { (countryCode) in
            
            if countryCode != "DE" {
                
                self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorLocationTitle"), message: String.localized("PetrolErrorLocationMessage"))
                
            } else {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                PetrolManager.shared.delegate = self
                PetrolManager.shared.sendRequest(coordiante: location.coordinate, radius: 5, sorting: .distance, type: .diesel)
                
            }
            
        }
        
    }
    
    func didFailWithError(error: Error) {
        
        
        
    }
    
    // MARK: - PetrolManagerDelegate
    
    func didReceivePetrolStations(stations: [PetrolStation]) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            let openStations = stations.filter { $0.isOpen && $0.price != nil }
            
            self.averagePetrolCardView.stopLoading()
            self.averagePetrolCardView.numberOfStations = openStations.count
            
            let sum = openStations.reduce(0) { (result, item) in
                
                return result + (item.price ?? 0)
                
            }
            
            let averagePrice = sum / Double(openStations.count)
            
            self.averagePetrolCardView.price = averagePrice
            
        }
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        previewingContext.sourceRect = averagePetrolCardView.frame
        
        return petrolStationVC()
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        showPetrolStationViewController()
        
    }
    
}
