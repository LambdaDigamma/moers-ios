//
//  DashboardController.swift
//  
//
//  Created by Lennart Fischer on 09.01.22.
//

import Foundation
import UIKit
import Core

public class DashboardController: UIViewController {
    
    var onOpenCurrentTrip: () -> Void
    
    public init(onOpenCurrentTrip: @escaping () -> Void) {
        self.onOpenCurrentTrip = onOpenCurrentTrip
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserActivity.current = UserActivities.configureDashboardActivity()
        
    }
    
    private func setupUI() {
        
        let dashboardView = DashboardView(openCurrentTrip: onOpenCurrentTrip, content: {})
        
        self.addSubSwiftUIView(dashboardView, to: view)
        
    }
    
}
