//
//  Datasources.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.03.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import Core

protocol TrackerDatasource {
    
    func didReceiveTrackers(_ trackers: [Tracker])
    
}

protocol LocationDatasource {
    
    func didReceiveLocations(_ locations: [Entry])
    
}
