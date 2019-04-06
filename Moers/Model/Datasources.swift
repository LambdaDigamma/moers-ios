//
//  Datasources.swift
//  Moers
//
//  Created by Lennart Fischer on 22.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation
import MMAPI

protocol ParkingLotDatasource {
    
    func didReceiveParkingLots(_ parkingLots: [ParkingLot])
    
}

protocol CameraDatasource {
    
    func didReceiveCameras(_ cameras: [Camera])
    
}

protocol PetrolDatasource {
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStation])
    
}

protocol EntryDatasource {
    
    func didReceiveEntries(_ entries: [Entry])
    
}
