//
//  AveragePetrolPriceComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 29.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import CoreLocation
import MMAPI

class AveragePetrolPriceComponent: BaseComponent, UIViewControllerPreviewingDelegate {

    private var petrolStations: [PetrolStation] = []
    private let locationManager: LocationManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    
    lazy var averagePetrolCardView: DashboardAveragePetrolPriceCardView = {
        
        let cardView = DashboardAveragePetrolPriceCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    init(viewController: UIViewController,
         locationManager: LocationManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         petrolManager: PetrolManagerProtocol) {
        
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        self.petrolManager = petrolManager
        
        super.init(viewController: viewController)
        
        self.register(view: averagePetrolCardView)
        self.viewController?.registerForPreviewing(with: self, sourceView: averagePetrolCardView)
        
        self.averagePetrolCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPetrolStationViewController)))
        self.averagePetrolCardView.petrolType = petrolManager.petrolType
        
        if MockConfig.isSnapshotting {
            
            self.averagePetrolCardView.dismissError()
            self.averagePetrolCardView.stopLoading()
            self.averagePetrolCardView.locationLabel.text = MockConfig.mocked.petrolCity
            self.averagePetrolCardView.numberOfStations = MockConfig.mocked.petrolNumberStations
            self.averagePetrolCardView.price = MockConfig.mocked.petrolPrice
            
            return
            
        }
        
        self.checkAuthStatusAndLoadIfNeeded()
        
    }
    
    override func update() {
        
        self.averagePetrolCardView.petrolType = petrolManager.petrolType
        
        self.checkAuthStatusAndLoadIfNeeded()
        
        // TODO: Check Update of Dashboard

    }
    
    override func refresh() {
        
        self.checkAuthStatusAndLoadIfNeeded()
        
    }
    
    override func invalidate() {
        
        // TODO: Stop Monitoring of LocationManager?!
        self.averagePetrolCardView.stopLoading()
        
    }
    
    // MARK: - Loading Petrol Stations Flow
    
    private func checkAuthStatusAndLoadIfNeeded() {
        
        locationManager.authorizationStatus
            .receive(on: DispatchQueue.main)
            .observeNext { authorizationStatus in
            
                if authorizationStatus == .authorizedWhenInUse {
                    self.averagePetrolCardView.dismissError()
                    self.averagePetrolCardView.isUserInteractionEnabled = true
                    self.loadCurrentLocation()
                } else {
                    self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorPermissionTitle"),
                                                         message: String.localized("PetrolErrorPermissionMessage"))
                    self.averagePetrolCardView.isUserInteractionEnabled = false
                }
                
        }.dispose(in: bag)
        
    }
    
    private func loadCurrentLocation() {
        
        self.averagePetrolCardView.startLoading()
        locationManager.requestCurrentLocation()
        
        let location = locationManager.location
        
        location.observeNext { location in
            self.loadPlacemark(for: location)
        }.dispose(in: bag) // Add Throtteling here
        
        location
            .receive(on: DispatchQueue.main)
            .observeFailed { error in
                // TODO: Show standard price for Moers
                print(error.localizedDescription)
                self.averagePetrolCardView.showError(withTitle: "Loading Location Failed.", message: "")
            }.dispose(in: bag)
        
    }
    
    private func loadPlacemark(for location: CLLocation) {
        
        geocodingManager.placemark(from: location)
            .receive(on: DispatchQueue.main)
            .observeNext { placemark in
            
                self.averagePetrolCardView.locationLabel.text = placemark.city
                
                if placemark.countryCode == "DE" {
                    self.loadPetrolPrice(for: location)
                } else {
                    self.averagePetrolCardView.isUserInteractionEnabled = false
                    self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorLocationTitle"),
                                                         message: String.localized("PetrolErrorLocationMessage"))
                }
            
            }.dispose(in: bag)
        
    }
    
    private func loadPetrolPrice(for location: CLLocation) {
        
        self.averagePetrolCardView.isUserInteractionEnabled = true
        
        let userPetrolPreference = petrolManager.petrolType
        
        let petrolStations = petrolManager.getPetrolStations(coordinate: location.coordinate,
                                                             radius: 5,
                                                             sorting: .distance,
                                                             type: userPetrolPreference,
                                                             shouldReload: false)
        
        petrolStations
            .receive(on: DispatchQueue.main)
            .observeNext { petrolStations in
                self.handleReceivedPetrolStations(petrolStations)
            }.dispose(in: bag)
        
        petrolStations.observeFailed { error in
            // TODO: Add Error Handling
        }.dispose(in: bag)
        
    }
    
    private func handleReceivedPetrolStations(_ petrolStations: [PetrolStation]) {
        
        self.averagePetrolCardView.stopLoading()
        
        let openStations = petrolStations.filter { $0.isOpen && $0.price != nil }
        
        let priceSum = openStations.reduce(0) { (result, item) in
            return result + (item.price ?? 0)
        }
        
        let priceAverage = priceSum / Double(openStations.count)
        
        // FIXME: Remove this property
        self.petrolStations = petrolStations
        
        self.averagePetrolCardView.stopLoading()
        self.averagePetrolCardView.numberOfStations = openStations.count
        self.averagePetrolCardView.price = priceAverage
        
    }
    
    // MARK: - View Controller Handling
    
    private func petrolStationVC() -> PetrolStationViewController {
        
        // TODO: Rebuild Analytics
        // AnalyticsManager.shared.logOpenedPetrolPrices(for: place)
        
        let petrolStationViewController = PetrolStationViewController(locationManager: locationManager,
                                                                      petrolManager: petrolManager,
                                                                      stations: petrolStations)
        
        return petrolStationViewController
        
    }
    
    @objc private func showPetrolStationViewController() {
        
        let petrolStationViewController = petrolStationVC()
        
        viewController?.navigationController?.pushViewController(petrolStationViewController, animated: true)
        
    }
    
    // MARK: - UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        previewingContext.sourceRect = averagePetrolCardView.frame
        
        return petrolStationVC()
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        showPetrolStationViewController()
        
    }
    
}
