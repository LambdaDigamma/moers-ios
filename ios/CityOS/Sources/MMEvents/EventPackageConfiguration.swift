//
//  EventPackageConfiguration.swift
//  
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import UIKit

public struct EventPackageConfiguration {
    nonisolated(unsafe) public static var eventActiveMinuteThreshold: Measurement<UnitDuration> = Measurement(value: 30.0, unit: .minutes)
    nonisolated(unsafe) public static var accentColor: UIColor = .systemBlue
    nonisolated(unsafe) public static var onAccentColor: UIColor = .white
}
