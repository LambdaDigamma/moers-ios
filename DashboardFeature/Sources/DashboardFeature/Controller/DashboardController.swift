//
//  DashboardController.swift
//  
//
//  Created by Lennart Fischer on 09.01.22.
//

import Foundation
import UIKit
import Core

class DashboardController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserActivity.current = UserActivities.configureDashboardActivity()
        
    }
    
    private func setupUI() {
        
        let dashboardView = DashboardView(content: {})
        
        self.addSubSwiftUIView(dashboardView, to: view)
        
    }
    
}
