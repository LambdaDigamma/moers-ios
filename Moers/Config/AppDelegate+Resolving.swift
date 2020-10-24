//
//  AppDelegate+Resolving.swift
//  Moers
//
//  Created by Lennart Fischer on 20.07.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import Foundation
import Resolver
import MMAPI

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        if #available(iOS 13.0, *) {
            register { NetworkingAPI.default as API }.scope(application)
            register { RemoteOrganisationRepository() as OrganisationRepository }.scope(application)
        }
    }
}
