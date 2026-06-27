//
//  TripDetailViewModel.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Foundation
import Combine
import FactoryKit
import EFAAPI
import Observation

@Observable
public class TripDetailViewModel {
    
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var duration: String = ""
    var numberOfChanges: Int = 0
    var origin: String = ""
    var destination: String = ""
    var startDate: Date = Date()
    
    @ObservationIgnored @Injected(\.tripService) var tripService
    
    var partialRoutes: [PartialRouteUiState] = []
    
    public init() {
        
    }
    
    public init(route: RouteUiState) {
        
        self.duration = route.duration
        self.numberOfChanges = route.numberOfChanges
        self.origin = route.origin
        self.destination = route.destination
        self.startDate = route.date
        self.partialRoutes = route.partialRoutes
        
    }
    
}
