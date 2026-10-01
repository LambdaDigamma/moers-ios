//
//  LicensesViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 18.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

class LicensesViewModel {
    
    public var text: String {
        
        var licenseString = ""
        
        License.loadFromPlist()
            .map({ "\($0.framework)\n\n\($0.name)\n\n\($0.text)" })
            .forEach { licenseString += "\($0)\n\n" }
        
        return licenseString
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
