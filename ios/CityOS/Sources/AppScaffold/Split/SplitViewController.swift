//
//  SplitViewController.swift
//  
//
//  Created by Lennart Fischer on 31.03.22.
//

import OSLog

extension OSLog {
    
    /// Use the Bundle ID as the subsystem
    internal static let subsystem = Bundle.main.bundleID
    
    /// UI
    internal static let ui = OSLog(subsystem: subsystem, category: "ui")
    
}


#if canImport(UIKit) && !os(tvOS) && os(iOS)
import UIKit
import Combine

@available(iOS 14.0, *)
open class SplitViewController: UISplitViewController, UISplitViewControllerDelegate, SidebarViewControllerDelegate {
    
    open var firstLaunch: FirstLaunch
    open var cancellables = Set<AnyCancellable>()
    public let logger: Logger = Logger(.ui)
    open var sidebarItems: [SidebarItem] = []
    
    open var sidebarController: SidebarViewController
    open var compactController: UIViewController?
    open var secondaryRootViewControllers: [UIViewController]
    
    open var onChangeTraitCollection: ((UITraitCollection) -> Void)?
    
    public init(
        firstLaunch: FirstLaunch = .init(userDefaults: .standard, key: "wasLaunchedBefore"),
        style: UISplitViewController.Style = .doubleColumn,
        sidebarController: SidebarViewController = .init(),
        compactController: UIViewController? = nil,
        secondaryRootViewControllers: [UIViewController] = []
    ) {
        self.firstLaunch = firstLaunch
        self.sidebarController = sidebarController
        self.secondaryRootViewControllers = secondaryRootViewControllers
        self.compactController = compactController
        super.init(style: style)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    open var isSnapshotting: Bool {
        return UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT")
    }
    
    open var displayCompact: Bool {
        return self.traitCollection.horizontalSizeClass == .compact
    }
    
    open func configureSplitController() {
        
        self.sidebarController.delegate = self
        
        self.delegate = self
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        self.showsSecondaryOnlyButton = true
        self.presentsWithGesture = true
        
        if #available(iOS 14.5, *) {
            self.displayModeButtonVisibility = .always
        }
        
        if let compactController = compactController {
            self.setViewController(compactController, for: .compact)
        }
        
        self.setViewController(sidebarController, for: .primary)
        
        if let firstRootViewController = secondaryRootViewControllers[safe: 0] {
            self.setViewController(firstRootViewController, for: .secondary)
        }
        
    }
    
    // MARK: - Trait Collection Changes -
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
        if let previousTraitCollection = previousTraitCollection {
            
            if previousTraitCollection.horizontalSizeClass != traitCollection.horizontalSizeClass &&
                traitCollection.userInterfaceIdiom == .pad {
                onChangeTraitCollection?(traitCollection)
            }
            
        }
        
    }
    
    // MARK: - Sidebar -
    
    open func sidebar(_ sidebarViewController: SidebarViewController, didSelectTabItem item: SidebarItem) {
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        
        if let index = sidebarItems.firstIndex(of: item) {
            let indexPath = IndexPath(item: index, section: 0)
            self.setViewController(secondaryRootViewControllers[indexPath.row], for: .secondary)
        }
        
    }
    
    // MARK: - UISplitViewControllerDelegate -
    
    open func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewController.DisplayMode) {
        
        self.logger.info("MainSplitViewController changes to \(displayMode.rawValue, privacy: .public)")
        
    }
    
    // MARK: - Actions -
    
    open func selectSidebarItem(_ item: SidebarItem) {
        
        self.preferredDisplayMode = .oneBesideSecondary
        self.presentsWithGesture = false
        self.preferredSplitBehavior = .tile
        self.primaryBackgroundStyle = .sidebar
        
        if let index = sidebarItems.firstIndex(of: item) {
            self.sidebarController.selectIndex(index)
            self.setViewController(secondaryRootViewControllers[index], for: .secondary)
        }
        
    }
    
}

#endif
