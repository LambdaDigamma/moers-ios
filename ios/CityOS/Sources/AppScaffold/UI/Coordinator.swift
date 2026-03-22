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
    
    var navigationController: CoordinatedNavigationController { get set }
    
}

public extension Coordinator {
    
    var rootViewController: UIViewController {
        return navigationController
    }
    
}

#endif
