//
//  DepartureMonitorLoader.swift
//  Moers
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import EFAAPI
import ModernNetworking

public class DepartureMonitorLoader: ObservableObject {

    private let transitService: DefaultTransitService

    public init() {

        let serverEnvironment = ServerEnvironment(scheme: "https", host: "openservice.vrr.de", pathPrefix: "vrr")
        let serverEnvironmentLoader = ApplyEnvironmentLoader(environment: serverEnvironment)
        let loader = URLSessionLoader()
        transitService = DefaultTransitService(loader: (serverEnvironmentLoader --> PrintLoader() --> loader)!)

    }

    public func fetch(station id: Station.ID) async throws -> DepartureMonitorResponse {
        return try await transitService.sendRawDepartureMonitorRequest(id: id)
    }

}
