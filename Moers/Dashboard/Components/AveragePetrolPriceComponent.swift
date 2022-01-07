//
//  AveragePetrolPriceComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 29.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Resolver
import Core
import UIKit
import CoreLocation
import MMAPI
import MMUI
import Combine

class AveragePetrolPriceComponent: BaseComponent {

    @LazyInjected var geocodingService: GeocodingService
    @LazyInjected var locationService: LocationService
    
    private var petrolStations: [PetrolStation] = []
    private let petrolManager: PetrolManagerProtocol
    private var cancellables = Set<AnyCancellable>()
    
    lazy var averagePetrolCardView: DashboardAveragePetrolPriceCardView = {
        
        let cardView = DashboardAveragePetrolPriceCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    init(
        viewController: UIViewController,
        petrolManager: PetrolManagerProtocol
    ) {
        
        self.petrolManager = petrolManager
        
        super.init(viewController: viewController)
        
        self.register(view: averagePetrolCardView)
        
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
        
        self.locationService.stopMonitoring()
        self.averagePetrolCardView.stopLoading()
        
    }
    
    // MARK: - Loading Petrol Stations Flow
    
    private func checkAuthStatusAndLoadIfNeeded() {
        
        locationService.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { authorizationStatus in
                
                if authorizationStatus == .authorizedWhenInUse {
                    self.averagePetrolCardView.dismissError()
                    self.averagePetrolCardView.isUserInteractionEnabled = true
                    self.loadCurrentLocation()
                } else {
                    self.averagePetrolCardView.showError(withTitle: String.localized("PetrolErrorPermissionTitle"),
                                                         message: String.localized("PetrolErrorPermissionMessage"))
                    self.averagePetrolCardView.isUserInteractionEnabled = false
                }
                
            })
            .store(in: &cancellables)
        
    }
    
    private func loadCurrentLocation() {
        
        self.averagePetrolCardView.startLoading()
        locationService.requestCurrentLocation()
        
        let location = locationService.location
        
        location
            .receive(on: DispatchQueue.main)
            .sink { (completion: Subscribers.Completion<Error>) in
            
                switch completion {
                    case .failure(let error):
                        print(error.localizedDescription)
                        self.averagePetrolCardView.showError(withTitle: "Loading Location Failed.", message: "")
                    default: break
                }
                
            } receiveValue: { (location: CLLocation) in
                self.loadPlacemark(for: location)
            }
            .store(in: &cancellables)
        
    }
    
    private func loadPlacemark(for location: CLLocation) {
        
        geocodingService.placemark(from: location)
            .receive(on: DispatchQueue.main)
            .sink { (_: Subscribers.Completion<Error>) in
                
            } receiveValue: { (placemark: CLPlacemark) in
                
                self.averagePetrolCardView.locationLabel.text = placemark.city
                
                if placemark.countryCode == "DE" {
                    self.loadPetrolPrice(for: location)
                } else {
                    self.averagePetrolCardView.isUserInteractionEnabled = false
                    self.averagePetrolCardView.showError(
                        withTitle: String.localized("PetrolErrorLocationTitle"),
                        message: String.localized("PetrolErrorLocationMessage")
                    )
                }
                
            }
            .store(in: &cancellables)

    }
    
    private func loadPetrolPrice(for location: CLLocation) {
        
        self.averagePetrolCardView.isUserInteractionEnabled = true
        
        let userPetrolPreference = petrolManager.petrolType
        
        let petrolStations = petrolManager.getPetrolStations(
            coordinate: location.coordinate,
            radius: 5,
            sorting: .distance,
            type: userPetrolPreference,
            shouldReload: false
        )
        
        petrolStations
            .receive(on: DispatchQueue.main)
            .sink { (_: Subscribers.Completion<Error>) in
                // TODO: Add Error Handling
            } receiveValue: { (petrolStations: [PetrolStation]) in
                self.handleReceivedPetrolStations(petrolStations)
            }
            .store(in: &cancellables)
        
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
        
        let petrolStationViewController = PetrolStationViewController(
            petrolManager: petrolManager,
            stations: petrolStations
        )
        
        return petrolStationViewController
        
    }
    
    @objc private func showPetrolStationViewController() {
        
        let petrolStationViewController = petrolStationVC()
        
        viewController?.navigationController?.pushViewController(petrolStationViewController, animated: true)
        
    }
    
}
