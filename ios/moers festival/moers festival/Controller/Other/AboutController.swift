//
//  AboutController.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.12.25.
//  Copyright © 2025 Code for Niederrhein. All rights reserved.
//

import UIKit
import SwiftUI

class AboutController: UIHostingController<About> {
    
    init(coordinator: OtherCoordinator) {
        super.init(rootView: About(
            onOpenReview: coordinator.openReview,
            onOpenDeveloperLink: coordinator.openDeveloperLink(of:)
        ))
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
