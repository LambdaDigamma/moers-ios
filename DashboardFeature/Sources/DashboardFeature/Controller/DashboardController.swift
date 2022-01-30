//
//  DashboardController.swift
//  
//
//  Created by Lennart Fischer on 09.01.22.
//

import Foundation
import UIKit

class DashboardController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func setupUI() {
        
        let dashboardView = DashboardView()
        
        self.addSubSwiftUIView(dashboardView, to: view)
        
    }
    
}
