//
//  DashboardViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import UserNotifications
import CoreLocation
import MapKit
import Intents
import MMAPI
import MMUI
import Resolver
import RubbishFeature

class DashboardViewController: CardCollectionViewController {
    
    @LazyInjected var rubbishService: RubbishService
    
    public var coordinator: DashboardCoordinator?
    
    private var components: [BaseComponent] = []
    
    private let locationManager: LocationManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    
    init(coordinator: DashboardCoordinator) {
        self.geocodingManager = coordinator.geocodingManager
        self.locationManager = coordinator.locationManager
        self.petrolManager = coordinator.petrolManager
        self.coordinator = coordinator
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(
        locationManager: LocationManagerProtocol,
        geocodingManager: GeocodingManagerProtocol,
        petrolManager: PetrolManagerProtocol
    ) {
    
        self.locationManager = locationManager
        self.geocodingManager = geocodingManager
        self.petrolManager = petrolManager
        
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("DashboardTabItem")
        
        self.registerComponents()
        
        self.extendedLayoutIncludesOpaqueBars = true
        self.isPullToRefreshEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.view.backgroundColor = UIColor.systemBackground
        self.collectionView.backgroundColor = UIColor.systemBackground
        
        self.triggerUpdate()
        
        AnalyticsManager.shared.logOpenedDashboard()
        
        self.setupIntents()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        components.forEach { $0.invalidate() }
        
    }
    
    // MARK: - Private Methods
    
    private func registerComponents() {
  
        let petrolPriceComponent = AveragePetrolPriceComponent(
            viewController: self,
            locationManager: locationManager,
            geocodingManager: geocodingManager,
            petrolManager: petrolManager
        )
        
        components.append(petrolPriceComponent)
        
        if UserManager.shared.user.type == .citizen {
            components.append(RubbishCollectionComponent(viewController: self))
        }
        
//        let covidComponent = CovidComponent(viewController: self,
//                                            locationManager: locationManager,
//                                            geocodingManager: geocodingManager, covidManager: CovidManager())
//
//        components.append(covidComponent)
        
        registerCardViews(components.map { $0.view })
        
    }
    
    public func triggerUpdate() {
        
        components.forEach { $0.update() }
        
    }
    
    public func triggerRefresh() {
        
        components.forEach { $0.refresh() }
        
    }
    
    public func reloadUI() {
        
        components.removeAll()
        
        registerComponents()
        
    }
    
    override func refresh() {
        
        UIView.animate(withDuration: 1) {
            self.collectionView.refreshControl?.endRefreshing()
        } completion: { _ in
            self.triggerRefresh()
        }

    }
    
    public func openRubbishViewController() {
        coordinator?.pushRubbishViewController()
    }
    
    private func setupIntents() {
        
        if rubbishService.isEnabled && rubbishService.rubbishStreet != nil {
            
            let activity = UserManager.shared.nextRubbishActivity()
            
            view.userActivity = activity
            activity.becomeCurrent()
            
        }
        
    }
    
}
