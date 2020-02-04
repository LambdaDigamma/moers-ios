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
import Reachability
import Intents
import MMAPI

class DashboardViewController: CardCollectionViewController {
    
    var coordinator: DashboardCoordinator?
    
    var components: [BaseComponent] = []
    
    private let locationManager: LocationManagerProtocol
    private let geocodingManager: GeocodingManagerProtocol
    private let petrolManager: PetrolManagerProtocol
    
    init(locationManager: LocationManagerProtocol,
         geocodingManager: GeocodingManagerProtocol,
         petrolManager: PetrolManagerProtocol) {
        
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
        
        if #available(iOS 13.0, *) {
            setupSettingsBarButtonItem()
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
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
  
        let petrolPriceComponent = AveragePetrolPriceComponent(viewController: self,
                                                               locationManager: locationManager,
                                                               geocodingManager: geocodingManager,
                                                               petrolManager: petrolManager)
        
        components.append(petrolPriceComponent)
        
        if UserManager.shared.user.type == .citizen {
            components.append(RubbishCollectionComponent(viewController: self))
        }
        
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
        
        UIView.animate(withDuration: 1, animations: {
            
            self.collectionView.refreshControl?.endRefreshing()
            
        }) { (_) in
            
            self.triggerRefresh()
            
        }
        
    }
    
    public func openRubbishViewController() {
        coordinator?.pushRubbishViewController()
    }
    
    private func setupIntents() {
        
        if RubbishManager.shared.isEnabled && RubbishManager.shared.rubbishStreet != nil {
            
            let activity = UserManager.shared.nextRubbishActivity()
            
            view.userActivity = activity
            activity.becomeCurrent()
            
        }
        
    }
    
    @available(iOS 13.0, *)
    private func setupSettingsBarButtonItem() {
        
        let item = UIBarButtonItem(image: UIImage(systemName: "slider.horizontal.3"), style: .plain, target: self, action: #selector(showSettings))
        
        self.navigationItem.rightBarButtonItem = item
        
    }
    
    @available(iOS 13.0, *)
    @objc private func showSettings() {
        
        coordinator?.showDashboardSettings()
        
    }
    
}
