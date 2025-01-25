//
//  TripConfigurationViewController.swift
//  
//
//  Created by Lennart Fischer on 05.04.22.
//

#if canImport(UIKit)

import UIKit
import SwiftUI
import EFAAPI

public class TripConfigurationViewController: UIHostingController<TripConfigurationScreen> {

    private let transitService: DefaultTransitService
    private let viewModel: TripSearchViewModel
    
    private var onSearch: (() -> Void)?
    
    public init() {
        
        self.transitService = DefaultTransitService(loader: DefaultTransitService.defaultLoader())
        self.viewModel = TripSearchViewModel(transitService: transitService)
        
        super.init(rootView: TripConfigurationScreen(
            viewModel: viewModel
        ))
        
        self.viewModel.onSearchEvent = {
            
            let viewController = TripSearchViewController(viewModel: self.viewModel)
            
            self.navigationController?.pushViewController(viewController, animated: true)
            
        }
        
    }
    
    @MainActor
    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let activity = TransportationUserActivity.configureTransportationOverview()
        
        activity.becomeCurrent()
        
//        self.view.window?.windowScene?.userActivity = activity
//
//        activity.becomeCurrent()
        
    }
    
}

#endif
