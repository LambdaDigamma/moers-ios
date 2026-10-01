//
//  StopDepartureViewModel.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import EFAAPI
import SwiftUI
import FactoryKit

@Observable
public class StopDepartureViewModel {
    
    var currentStop: TransitLocation? = nil
    
    public init() {
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
