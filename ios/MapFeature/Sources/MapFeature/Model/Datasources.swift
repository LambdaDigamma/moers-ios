//
//  Datasources.swift
//  Moers
//
//  Created by Lennart Fischer on 22.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import Foundation
//import ParkingFeature

//protocol ParkingLotDatasource {
//
//    func didReceiveParkingLots(_ parkingLots: [ParkingArea])
//
//}

protocol CameraDatasource {
    
    func didReceiveCameras(_ cameras: [Camera])
    
}

protocol PetrolDatasource {
    
    func didReceivePetrolStations(_ petrolStations: [PetrolStationViewModel])
    
}

protocol EntryDatasource {
    
    func didReceiveEntries(_ entries: [Entry])
    
}
