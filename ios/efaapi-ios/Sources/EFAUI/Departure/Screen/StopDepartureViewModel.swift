//
//  StopDepartureViewModel.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import EFAAPI
import SwiftUI
import Factory

public class StopDepartureViewModel: ObservableObject {
    
    @Published var currentStop: TransitLocation? = nil
    
    public init() {
        
    }
    
}
