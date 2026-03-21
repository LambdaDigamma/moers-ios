//
//  TabRepresentable.swift
//  CityOS
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(UIKit) && os(iOS)

import UIKit

@MainActor
@available(iOS 14.0, *)
public protocol TabRepresentable: AnyObject {
    
    var rootViewController: UIViewController { get }
    
    var tabBarItem: UITabBarItem? { get }
    
}

@MainActor
@available(iOS 14.0, *)
public extension TabRepresentable where Self: Coordinator {
    
    var tabBarItem: UITabBarItem? {
        return navigationController.tabBarItem
    }
    
}

@MainActor
@available(iOS 14.0, *)
public final class ViewControllerTab: TabRepresentable {
    
    public let viewController: UIViewController
    
    public init(_ viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public var rootViewController: UIViewController {
        return viewController
    }
    
    public var tabBarItem: UITabBarItem? {
        get { viewController.tabBarItem }
        set { viewController.tabBarItem = newValue }
    }
    
}

#endif
