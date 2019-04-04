//
//  Config.swift
//  Moers
//
//  Created by Lennart Fischer on 04.04.19.
//  Copyright © 2019 Lennart Fischer. All rights reserved.
//

import Foundation

struct Config {
    
    var petrolCity: String = "Moers"
    var petrolPrice: Double = 1.19
    var petrolNumberStations: Int = 20
    var petrolType = PetrolType.diesel
    
    static var mocked: Config {
        return Config()
    }
    
    static var isSnapshotting: Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
}
