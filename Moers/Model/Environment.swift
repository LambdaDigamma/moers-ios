//
//  Environment.swift
//  Moers
//
//  Created by Lennart Fischer on 30.09.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct Environment {
    
    var name: String
    var baseURL: String
    var clientID: Int
    var clientSecret: String
    var type: EnvironmentType
    
    enum EnvironmentType: String {
        case production = "Production"
        case beta = "Beta"
        case local = "Local"
    }
    
    static var all: [Environment.EnvironmentType: Environment] = [.production: Environment(name: "Production", baseURL: "https://meinmoers.lambdadigamma.com/", clientID: 4, clientSecret: "qRwT7QC1MIyQVTpSm2QnttieSOaFKWrqdn4j0vNh", type: .production),
                                                                  .local: Environment(name: "Local", baseURL: "http://localhost:8080/", clientID: 2, clientSecret: "2l564wXWihfjFzJoqES6P1gRtQtDnL5yr8XxBRV6", type: .local)]
    
    static var current: Environment {
        guard let env = Environment.all[.local] else { fatalError("No Environment set!") }
        return env
    }
    
}
