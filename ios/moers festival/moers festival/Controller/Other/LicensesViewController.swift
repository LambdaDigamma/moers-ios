//
//  LicensesViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class LicensesViewController: UIViewController {

    // MARK: - Properties
    
    public var coordinator: OtherCoordinator?
    
    private let viewModel: LicensesViewModel
    private let licensesView: LicensesView
    
    init(viewModel: LicensesViewModel) {
        self.viewModel = viewModel
        self.licensesView = LicensesView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func loadView() {
        view = licensesView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.title = String(localized: "Licenses")
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

#if DEBUG
#Preview("Licenses, wide", traits: .fixedLayout(width: 951, height: 669)) {
    let coordinator = OtherCoordinator()
    let controller = coordinator.rootViewController
    controller.traitOverrides.horizontalSizeClass = .regular
    coordinator.showLicense()
    return controller
}

#Preview("Licenses, narrow", traits: .fixedLayout(width: 466, height: 678)) {
    let coordinator = OtherCoordinator()
    let controller = coordinator.rootViewController
    controller.traitOverrides.horizontalSizeClass = .compact
    coordinator.showLicense()
    return controller
}
#endif
