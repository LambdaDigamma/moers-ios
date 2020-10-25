//
//  CovidComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI
import CoreLocation
import Combine

class CovidComponent: BaseComponent {
    
    private let locationManager: LocationManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    private let covidManager: CovidManagerProtocol
    
    private var cancellableBag = Set<AnyCancellable>()
    
    var locationObject: CoreLocationObject
    
    lazy var covidCardView: DashboardCovidCardView = {
        
        let cardView = DashboardCovidCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    init(viewController: UIViewController,
         locationManager: LocationManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         covidManager: CovidManagerProtocol) {
        
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        self.covidManager = covidManager
        self.locationObject = CoreLocationObject()
        
        super.init(viewController: viewController)
        
        self.register(view: covidCardView)
        
        self.covidCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPetrolStationViewController)))
        
        if MockConfig.isSnapshotting {
            
            self.covidCardView.dismissError()
            self.covidCardView.stopLoading()
            // TODO: Set something
            
            return
            
        }
        
        self.checkAuthStatusAndLoadIfNeeded()
        
    }
    
    override func update() {
        
        self.checkAuthStatusAndLoadIfNeeded()
        
    }
    
    override func refresh() {
        
        self.checkAuthStatusAndLoadIfNeeded()
        
    }
    
    override func invalidate() {
        
        // TODO: Stop Monitoring of LocationManager?!
        self.covidCardView.stopLoading()
        
    }
    
    // MARK: - Loading Petrol Stations Flow
    
    private func checkAuthStatusAndLoadIfNeeded() {
        
        locationManager.authorizationStatus
            .receive(on: DispatchQueue.main)
            .observeNext { authorizationStatus in
                
                if authorizationStatus == .authorizedWhenInUse {
                    self.covidCardView.dismissError()
                    self.covidCardView.isUserInteractionEnabled = true
                    self.loadCurrentLocation()
                } else {
                    self.covidCardView.showError(withTitle: "Die App hat keine Erlaubnis, Deinen Standort zu benutzen.",
                                                         message: "Erlaube dies in den Einstellungen.")
                    self.covidCardView.isUserInteractionEnabled = false
                }
                
            }.dispose(in: bag)
        
    }
    
    private func loadCurrentLocation() {
        
        self.covidCardView.startLoading()
        locationManager.requestCurrentLocation()
        
        let location = locationManager.location
        
        
        
        location.observeNext { location in
            print("Location: \(location)")
            self.loadPetrolPrice(for: location)
        }.dispose(in: bag) // Add Throtteling here
        
        location
            .receive(on: DispatchQueue.main)
            .observeFailed { error in
                // TODO: Show standard price for Moers
                print(error.localizedDescription)
                self.covidCardView.showError(withTitle: "Deine Position konnte nicht bestimmt werden.", message: "")
            }.dispose(in: bag)
        
    }
    
    private func loadPetrolPrice(for location: CLLocation) {
        
        self.covidCardView.isUserInteractionEnabled = true
        
        covidManager.getData(location: location.coordinate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
            
            print(completion)
            
        }, receiveValue: { (response) in
            
            print(response)
            
            if let attributes = response.features.first?.attributes {
                self.covidCardView.viewModel = CovidIncidenceViewModel(rkiAttributes: attributes)
            }
            
            self.covidCardView.stopLoading()
            
        }).store(in: &cancellableBag)
        
    }
    
    private func handleReceivedPetrolStations(_ petrolStations: [PetrolStation]) {
        
        self.covidCardView.stopLoading()
        
        // FIXME: Remove this property
//        self.petrolStations = petrolStations
        
        self.covidCardView.stopLoading()
//        self.covidCardView.numberOfStations = openStations.count
//        self.covidCardView.price = priceAverage
        
    }
    
    // MARK: - View Controller Handling
    
    private func showMoersCovidDetails() -> UIViewController {
        
        return UIViewController()
    }
    
    @objc private func showPetrolStationViewController() {
        
        let moersCovidInformation = showMoersCovidDetails()
        
        viewController?.navigationController?.pushViewController(moersCovidInformation, animated: true)
        
    }
    
}
