//
//  AppConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import Foundation
import AppScaffold

nonisolated struct AppConfiguration: AppConfigurable {
    
    var minVersion: String
    var structure: AppStructure?
    
}

nonisolated struct AppStructure: Codable {
    
    var initialView: AppView?
    
}

nonisolated struct AppView: Codable {
    var type: String
    var title: String?
    var imageName: String?

    var children: [AppView]?
}
