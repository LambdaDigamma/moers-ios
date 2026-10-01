//
//  StandardRequestParameters.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation

nonisolated public struct StandardRequestParameters: Codable {
    public var isStateless: Bool = true
    public var isLocationServerActive: Bool = true
    public var coordinateOutputFormat: CoordinateOutputFormat = .wgs84
}
