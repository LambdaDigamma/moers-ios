//
//  LoRaManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.06.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

final class LoRaManager: Sendable {

    public static let shared = LoRaManager()
    
    private let session = URLSession.shared
    private let loRaServer = "http://m090web3.krzn.de:1880/"
    
}
