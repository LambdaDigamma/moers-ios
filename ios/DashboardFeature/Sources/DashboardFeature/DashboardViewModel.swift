//
//  DashboardViewModel.swift
//  Moers
//
//  Created by Lennart Fischer on 20.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import Combine
import EFAAPI
import Factory

public class DashboardViewModel: ObservableObject {
    
    private let loader: DashboardConfigLoader
    private var cancellables = Set<AnyCancellable>()
    
    @Published var displayables: [DashboardItemConfigurable] = []
    @Published var currentTrip: CachedEFATrip?
    
    @Injected(\.tripService) var tripService
    
    public init(loader: DashboardConfigLoader) {
        
        self.loader = loader
        self.reloadTripOnDashboard()
        
        NotificationCenter.default.publisher(for: .SetupDidComplete)
            .sink { _ in
                self.load()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .updateDashboard)
            .sink { _ in
                self.load()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .activatedTrip)
            .sink { _ in
                self.reloadTripOnDashboard()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .deactivatedTrip)
            .sink { _ in
                self.reloadTripOnDashboard()
            }
            .store(in: &cancellables)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// Loads the config via the provided `DashboardConfigLoader`
    /// and transforms them into dashboard config models.
    public func load() {
        
        loader
            .load()
            .sink { [weak self] (config: DashboardConfig) in
                
                self?.displayables = config.items
                
            }
            .store(in: &cancellables)
        
    }
    
    public func reloadTripOnDashboard() {
        
        self.currentTrip = self.tripService.currentTrip
        
    }
    
}
