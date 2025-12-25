//
//  ParkingAreaFilterType.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import Foundation

public enum ParkingAreaFilterType: Int, CaseIterable {
    
    case all
    case onlyOpen
    
    var title: String {
        switch self {
            case .all:
                return PackageStrings.ParkingAreaList.filterAll
            case .onlyOpen:
                return PackageStrings.ParkingAreaList.filterOnlyOpen
        }
    }
}
