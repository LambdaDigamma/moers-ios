//
//  TripDetailViewModel.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import Foundation
import Combine
import Factory
import EFAAPI

public class TripDetailViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var duration: String = ""
    @Published var numberOfChanges: Int = 0
    @Published var origin: String = ""
    @Published var destination: String = ""
    @Published var startDate: Date = Date()
    
    @Injected(\.tripService) var tripService
    
    @Published var partialRoutes: [PartialRouteUiState] = []
    
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
