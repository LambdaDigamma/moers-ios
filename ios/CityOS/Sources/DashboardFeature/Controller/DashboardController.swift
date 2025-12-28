//
//  DashboardController.swift
//  
//
//  Created by Lennart Fischer on 09.01.22.
//

import Foundation
import UIKit
import Core
import SwiftUI

public class DashboardController: DefaultHostingController {
    
    var onOpenCurrentTrip: () -> Void
    
    public init(onOpenCurrentTrip: @escaping () -> Void) {
        self.onOpenCurrentTrip = onOpenCurrentTrip
//        super.init(nibName: nil, bundle: nil)
        super.init()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = String(localized: "Today", bundle: .module)
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UserActivity.current = UserActivities.configureDashboardActivity()
        
    }
    
    public override func hostView() -> AnyView {
        
        DashboardView(openCurrentTrip: onOpenCurrentTrip, content: {})
            .toAnyView()
        
    }
    
}
