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
        
        self.title = String.localized("LicensesTitle")
        
    }
    
}
