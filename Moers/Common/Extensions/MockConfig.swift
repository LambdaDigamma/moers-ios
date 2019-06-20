//
//  MockConfig.swift
//  Moers
//
//  Created by Lennart Fischer on 04.04.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Foundation
import MMAPI

struct MockConfig {
    
    var petrolCity: String = "Moers"
    var petrolPrice: Double = 1.19
    var petrolNumberStations: Int = 20
    var petrolType = PetrolType.diesel
    
    static var mocked: MockConfig {
        return MockConfig()
    }
    
    static var isSnapshotting: Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
}
