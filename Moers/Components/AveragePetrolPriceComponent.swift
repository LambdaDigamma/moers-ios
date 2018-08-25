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

    private var place: String = ""
    private var petrolStations: [PetrolStation] = []
    private var isAllowed: Bool { return !(LocationManager.shared.authorizationStatus == .restricted) && !(LocationManager.shared.authorizationStatus == .denied) }
    
    lazy var averagePetrolCardView: DashboardAveragePetrolPriceCardView = {
        
        let cardView = DashboardAveragePetrolPriceCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    override init(viewController: UIViewController) {
        super.init(viewController: viewController)
        
        self.register(view: averagePetrolCardView)
        self.viewController?.registerForPreviewing(with: self, sourceView: averagePetrolCardView)
        self.averagePetrolCardView.startLoading()
        
        PetrolManager.shared.delegate = self
        
        if let testing = ProcessInfo.processInfo.environment["-Test"], testing == "true" {
            
            self.averagePetrolCardView.dismissError()
            self.averagePetrolCardView.stopLoading()
            self.averagePetrolCardView.locationLabel.text = "Moers"
            self.averagePetrolCardView.numberOfStations = 10
            self.averagePetrolCardView.price = 1.25
            
            return
            
        }
        
        if isAllowed {
            
            self.averagePetrolCardView.dismissError()
            self.averagePetrolCardView.startLoading()
            
            if let location = LocationManager.shared.lastLocation {
                
                self.setupLocation(location)
                
            } else {
                
                LocationManager.shared.getCurrentLocation { (location, error) in
                    
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    
                    guard let location = location else { return }
                    
                    self.setupLocation(location)
                    
                }
                
            }
            
            self.averagePetrolCardView.isUserInteractionEnabled = true
            self.averagePetrolCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPetrolStationViewController)))
            
        } else {
            self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorPermissionTitle"), message: String.localized("PetrolErrorPermissionMessage"))
            self.averagePetrolCardView.isUserInteractionEnabled = false
        }
        
        self.averagePetrolCardView.petrolType = PetrolManager.shared.petrolType
        
        self.checkAuthStatus()
        self.averagePetrolCardView.startLoading()
        
    }
    
    override func update() {
        
        self.averagePetrolCardView.petrolType = PetrolManager.shared.petrolType
        
        self.checkAuthStatus()
        
        // TODO: Check Update of Dashboard
                
    }
    
    override func refresh() {
        
        LocationManager.shared.getCurrentLocation { (location, error) in
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            guard let location = location else { return }
            
            self.setupLocation(location)
            
        }
        
    }
    
    override func invalidate() {
        
        // TODO: Stop Monitoring of LocationManager?!
        self.averagePetrolCardView.stopLoading()
        
    }
    
    private func checkAuthStatus() {
        
        if isAllowed {
            self.averagePetrolCardView.dismissError()
            self.averagePetrolCardView.isUserInteractionEnabled = true
        } else {
            self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorPermissionTitle"), message: String.localized("PetrolErrorPermissionMessage"))
            self.averagePetrolCardView.isUserInteractionEnabled = false
        }
        
    }
    
    private func setupLocation(_ location: CLLocation) {
        
        loadPetrolPriceForLocation(location)
        
        geocodeLocation(location)
        
    }
    
    private func geocodeLocation(_ location: CLLocation) {
        
        DispatchQueue.global(qos: .background).async {
            
            GeocodingManager.shared.countryCode(from: location) { (countryCode) in
                
                DispatchQueue.main.async {
                    
                    if countryCode != "DE" {
                        
                        self.averagePetrolCardView.isUserInteractionEnabled = false
                        self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorLocationTitle"), message: String.localized("PetrolErrorLocationMessage"))
                        
                    } else {
                        
                        self.averagePetrolCardView.isUserInteractionEnabled = true
                        
                    }
                    
                }
                
            }
            
            GeocodingManager.shared.city(from: location) { (city) in
                
                DispatchQueue.main.async {
                    self.place = city ?? ""
                    self.averagePetrolCardView.locationLabel.text = city
                }
                
            }
            
        }
        
    }
    
    private func loadPetrolPriceForLocation(_ location: CLLocation) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        PetrolManager.shared.delegate = self
        PetrolManager.shared.sendRequest(coordiante: location.coordinate, radius: 5, sorting: .distance, type: .diesel)
        
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
                
                self.averagePetrolCardView.isUserInteractionEnabled = false
                self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorLocationTitle"), message: String.localized("PetrolErrorLocationMessage"))
                
            } else {
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
                
                PetrolManager.shared.delegate = self
                PetrolManager.shared.sendRequest(coordiante: location.coordinate, radius: 5, sorting: .distance, type: .diesel)
                self.averagePetrolCardView.isUserInteractionEnabled = true
                
            }
            
        }
        
    }
    
    func didFailWithError(error: Error) {
        
        
        
    }
    
    // MARK: - PetrolManagerDelegate
    
    func didReceivePetrolStations(stations: [PetrolStation]) {
        
        DispatchQueue.main.async {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            self.petrolStations = stations
            
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
