//
//  LoRaManager.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.06.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import Reachability
import Bond
import ReactiveKit

class LoRaManager {
    
    public static var shared = LoRaManager()
    
    private let reachability = Reachability()!
    private let bag = DisposeBag()
    private let session = URLSession.shared
    private let loRaServer = "http://m090web3.krzn.de:1880/"
    
    
    
    
    
}
