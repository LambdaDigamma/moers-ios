//
//  LicencesViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 18.08.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import SwiftUI
import Foundation
import LicenseUI

public class LicencesViewController: DefaultHostingController {
    
    private let viewModel: LicensesViewModel
    
    public override init() {
        self.viewModel = .init(loader: SettingsBundleLicenseLoader())
        super.init()
        self.title = String.localized("Licences")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI -
    
    public override func hostView() -> AnyView {
        
        LicensesList(viewModel: viewModel)
            .toAnyView()
        
    }
    
}
