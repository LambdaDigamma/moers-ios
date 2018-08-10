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

        self.registerComponents()
        
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
    
    private func registerComponents() {
  
        if UserManager.shared.user.type == .citizen {
            components.append(AveragePetrolPriceComponent(viewController: self))
        }

        components.append(RubbishCollectionComponent(viewController: self))
        
        registerCardViews(components.map { $0.view })
        
    }
    
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
    
    public func triggerUpdate() {
        
        components.forEach { $0.update() }
        
    }
    
    public func reloadUI() {
        
        components.removeAll()
        
        registerComponents()
        
    }
    
}
