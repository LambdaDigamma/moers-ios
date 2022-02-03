//
//  FuelStationListViewController.swift
//  
//
//  Created by Lennart Fischer on 03.02.22.
//

#if canImport(UIKit)
import Foundation
import UIKit
import SwiftUI

public class FuelStationListViewController: UIHostingController<PetrolStationList> {
    
    private let viewModel = PetrolPriceDashboardViewModel()
    
    public init() {
        super.init(rootView: PetrolStationList(viewModel: viewModel))
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.load()
        
    }
    
    @MainActor @objc required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#endif
