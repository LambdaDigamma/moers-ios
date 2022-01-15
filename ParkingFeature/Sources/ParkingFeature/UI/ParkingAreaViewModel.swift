//
//  ParkingAreaViewModel.swift
//  
//
//  Created by Lennart Fischer on 14.01.22.
//

import Foundation

public class ParkingAreaViewModel: ObservableObject, Identifiable {
    
    public let id: UUID = UUID()
    public let title: String
    public let free: Int
    public let total: Int
    public let currentOpeningState: ParkingAreaOpeningState
    
    public init(
        title: String,
        free: Int,
        total: Int,
        currentOpeningState: ParkingAreaOpeningState
    ) {
        self.title = title
        self.free = free
        self.total = total
        self.currentOpeningState = currentOpeningState
    }
    
    public var percentage: Double {
        return Double(free) / Double(total)
    }
    
}
