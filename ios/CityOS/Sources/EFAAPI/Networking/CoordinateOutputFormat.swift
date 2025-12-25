//
//  CoordinateOutputFormat.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import Foundation

/// The output format of coordinates of the points
public enum CoordinateOutputFormat: String, Codable {
    case wgs84 = "WGS84[DD.DDDDD]"
}
