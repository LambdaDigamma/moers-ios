//
//  AppConfiguration.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

import Foundation

@available(iOS 14.0, *)
public protocol AppConfigurable: Codable {
    var minVersion: String { get set }
}
