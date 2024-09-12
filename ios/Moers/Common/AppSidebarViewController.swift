//
//  AppSidebarViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 07.01.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import UIKit
import Combine
import SwiftUI
import AppScaffold
import Core

public class AppSidebarViewController: AppScaffold.SidebarViewController {
    
    public override init() {
        
        super.init()
        
        self.sidebarTitle = CoreSettings.appName
        self.sections = [SidebarSection.tabs]
        self.sectionItemProducer = { (section: SidebarSection) in
            switch section {
                case .tabs:
                    return SidebarItem.tabs
                default:
                    return []
            }
        }
        
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
