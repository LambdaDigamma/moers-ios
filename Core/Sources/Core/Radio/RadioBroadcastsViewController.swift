//
//  RadioBroadcastsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 24.09.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import UIKit

public class RadioBroadcastsViewController: UIViewController {
    
    public let radioService: RadioServiceProtocol = RadioService()
    public let viewModel: BroadcastListViewModel
    
    public init() {
        self.viewModel = BroadcastListViewModel(service: radioService)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        let list = BroadcastList(viewModel: viewModel)
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.addSubSwiftUIView(list, to: view)
        
    }
    
}
