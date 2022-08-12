//
//  FuelStationListViewController.swift
//  
//
//  Created by Lennart Fischer on 03.02.22.
//

#if canImport(UIKit)
import Core
import Foundation
import UIKit
import SwiftUI

public class FuelStationListViewController: UIHostingController<FuelStationList> {
    
    private let viewModel = PetrolPriceDashboardViewModel()
    
    public init() {
        super.init(rootView: FuelStationList(viewModel: viewModel))
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.load()
        UserActivity.current = UserActivities.configureFuelStations()
        
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#endif
