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

class DashboardViewController: CardCollectionViewController {
    
    var components: [BaseComponent] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let rubbishComponent = RubbishCollectionComponent(viewController: self)
        let petrolComponent = AveragePetrolPriceComponent(viewController: self)
        
        self.registerComponents(components: [petrolComponent, rubbishComponent])
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.triggerUpdate()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        components.forEach { $0.invalidate() }
        
    }
    
    // MARK: - Private Methods
    
    private func setupReachability() {
        
        guard let reachability = Reachability() else { return }
        
        reachability.whenReachable = { reachability in
            
            if reachability.connection == .cellular {
                
            } else if reachability.connection == .wifi {
                
            }
            
        }
        
        reachability.whenUnreachable = { _ in
            
            
            
        }
        
    }
    
    private func registerComponents(components: [BaseComponent]) {
        
        self.components = components
        
        registerCardViews(components.map { $0.view })
        
    }
    
    public func triggerUpdate() {
        
        components.forEach { $0.update() }
        
    }
    
}
