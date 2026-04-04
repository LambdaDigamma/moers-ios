//
//  Coordinator.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

import Foundation

#if canImport(UIKit) && os(iOS)

import UIKit

@available(iOS 14.0, *)
public protocol Coordinator: AnyObject, TabRepresentable {
    
    var rootViewController: UIViewController { get }
    
}

#endif
