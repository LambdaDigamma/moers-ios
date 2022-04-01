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

public class ParkingDashboardViewModel: StandardViewModel {
    
    @LazyInjected var parkingService: ParkingService
    
    @Published var parkingAreas: DataState<[ParkingArea], Error> = .loading
    
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
                self.parkingAreas = .success(data.parkingAreas)
            }
            .store(in: &cancellables)
        
    }
    
}
