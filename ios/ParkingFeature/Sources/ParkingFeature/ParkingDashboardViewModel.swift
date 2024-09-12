//
//  ParkingDashboardViewModel.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

import Foundation
import Core
import Resolver
import Combine

public struct ParkingDashboardViewData {
    
    public let parkingAreas: [ParkingArea]
    public let minimalLastUpdate: Date
    
    init(parkingAreas: [ParkingArea], minimalLastUpdate: Date) {
        self.parkingAreas = parkingAreas
        self.minimalLastUpdate = minimalLastUpdate
    }
    
    var isOutOfDate: Bool {
        
        let containsNegativeCapacity = parkingAreas.contains { (parkingArea: ParkingArea) in
            return parkingArea.freeSites < 0 || parkingArea.capacity ?? 0 < 0
        }
        
        let timeIntervalIsOld = abs(minimalLastUpdate.timeIntervalSinceNow) >= 60 * 60 * 24
        
        return containsNegativeCapacity || timeIntervalIsOld
        
    }
    
}

public class ParkingDashboardViewModel: StandardViewModel {
    
    @LazyInjected var parkingService: ParkingService
    
    @Published var parkingAreas: DataState<ParkingDashboardViewData, Error> = .loading
    
    public init(parkingService: ParkingService? = nil) {
        
        super.init()
        
        if let parkingService = parkingService {
            self.parkingService = parkingService
        }
        
    }
    
    public func load() {
        
        parkingService.loadDashboard()
            .sink { (completion: Subscribers.Completion<Error>) in
                
                if let error = completion.error {
                    self.parkingAreas = .error(error)
                }
                
            } receiveValue: { (data: ParkingDashboardData) in
                
                let minimalDate = data.parkingAreas
                    .sorted(by: { $0.updatedAt ?? Date.distantPast > $1.updatedAt ?? Date.distantPast })
                    .first?
                    .updatedAt
                
                let viewData = ParkingDashboardViewData(
                    parkingAreas: data.parkingAreas,
                    minimalLastUpdate: minimalDate ?? Date()
                )
                self.parkingAreas = .success(viewData)
                
            }
            .store(in: &cancellables)
        
    }
    
}
