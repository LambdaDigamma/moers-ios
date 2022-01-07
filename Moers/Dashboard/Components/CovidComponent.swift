//
//  CovidComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 25.10.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import UIKit
import MMUI
import MMAPI
import CoreLocation
import Combine
import SwiftUI
import OSLog
import Core
import Resolver

class CovidComponent: BaseComponent {
    
    private let locationManager: LocationManagerProtocol
    private let covidManager: CovidManagerProtocol
    
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(.ui)
    
    var locationObject: CoreLocationObject
    
    lazy var covidCardView: CardView = {
        
        let cardView = CardView()
        
        if let viewController = viewController {
            let childView = UIHostingController(rootView: Text("Test"))
            viewController.addChild(childView)
            childView.view.frame = cardView.bounds
            cardView.addConstrained(subview: childView.view)
            childView.didMove(toParent: viewController)
            
            let cardView = DashboardCovidCardView()
            
            cardView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        return cardView
        
    }()
    
    init(
        viewController: UIViewController,
        locationManager: LocationManagerProtocol,
        covidManager: CovidManagerProtocol
    ) {
        
        self.locationManager = locationManager
        self.covidManager = covidManager
        self.locationObject = CoreLocationObject()
        
        super.init(viewController: viewController)
        
        self.register(view: covidCardView)
        
        self.covidCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPetrolStationViewController)))
        
        if MockConfig.isSnapshotting {
            
            self.covidCardView.dismissError()
            self.covidCardView.stopLoading()
            
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
        
        self.locationManager.stopMonitoring() // is this right?
        self.covidCardView.stopLoading()
        
    }
    
    // MARK: - Loading Petrol Stations Flow
    
    private func checkAuthStatusAndLoadIfNeeded() {
        
        locationManager.authorizationStatus
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { authorizationStatus in
                if authorizationStatus == .authorizedWhenInUse {
                    self.covidCardView.dismissError()
                    self.covidCardView.isUserInteractionEnabled = true
                    self.loadCurrentLocation()
                } else {
                    self.covidCardView.showError(
                        withTitle: "Die App hat keine Erlaubnis, Deinen Standort zu benutzen.",
                        message: "Erlaube dies in den Einstellungen."
                    )
                    self.covidCardView.isUserInteractionEnabled = false
                }
            })
            .store(in: &cancellables)
        
    }
    
    private func loadCurrentLocation() {
        
        self.covidCardView.startLoading()
        locationManager.requestCurrentLocation()
        
        let location = locationManager.location
        
        location.sink { (completion: Subscribers.Completion<Error>) in
        
            switch completion {
                case .failure(let error):
                    // TODO: Show standard price for Moers
                    self.logger.error("Loading current location failed: \(error.localizedDescription)")
                    self.covidCardView.showError(
                        withTitle: "Deine Position konnte nicht bestimmt werden.",
                        message: ""
                    )
                default: break
            }
            
        } receiveValue: { (location: CLLocation) in
            print("Location: \(location)")
            self.loadPetrolPrice(for: location)
        }
        .store(in: &cancellables)
        
    }
    
    private func loadPetrolPrice(for location: CLLocation) {
        
        self.covidCardView.isUserInteractionEnabled = true
        
        covidManager.getCovidDataWithTrends(for: location.coordinate)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { (completion) in
            
            print(completion)
            
        }, receiveValue: { (response) in
            
            print(response)
            
//            self.covidCardView.viewModel = CovidIncidenceViewModel(incidenceResponse: response)
            
//            if let attributes = response.features.first?.attributes {
//                self.covidCardView.viewModel = CovidIncidenceViewModel(rkiAttributes: attributes)
//            }
            
            self.covidCardView.stopLoading()
            
        }).store(in: &cancellables)
        
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
