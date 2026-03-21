//
//  BootstrappingProcedure.swift
//  
//
//  Created by Lennart Fischer on 03.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
public protocol BootstrappingProcedureStep {
    
    func execute(with application: UIApplication)
    
}

public typealias BootstrappingProcedure = [BootstrappingProcedureStep]

@available(iOS 14.0, *)
public extension Collection where Element == BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        self.forEach { $0.execute(with: application) }
    }
    
}

#endif
