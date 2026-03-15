//
//  AppSidebarViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 31.03.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import AppScaffold
import UIKit

public extension SidebarSection {
    
    static let tabs = SidebarSection(
        title: nil,
        isCollapsable: false
    )
    
}

public class AppSidebarViewController: AppScaffold.SidebarViewController {
    
    public override init() {
        
        super.init()
        
        self.sidebarTitle = "moers festival"
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
