//
//  AppConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import Foundation
import AppScaffold

struct AppConfiguration: AppConfigurable {
    
    var minVersion: String
    var structure: AppStructure?
    
}

struct AppStructure: Codable {
    
    var initialView: AppView?
    
}

struct AppView: Codable {
    var type: String
    var title: String?
    var imageName: String?

    var children: [AppView]?
}
