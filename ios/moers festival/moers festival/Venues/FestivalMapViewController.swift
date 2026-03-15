//
//  FestivalMapViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import UIKit
import Core
import MMEvents
import SwiftUI

public class FestivalMapViewController: DefaultHostingController {

    private let viewModel: FestivalMapViewModel
    
    public override init() {
        
        self.viewModel = FestivalMapViewModel()
        super.init()
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
//        let drawer = DrawerFestivalMapViewController(viewModel: viewModel)
        
        let drawer = UIViewController()
        drawer.view.backgroundColor = UIColor.secondarySystemBackground
        
        if let sheet = drawer.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }
        
        present(drawer, animated: true)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    public override func hostView() -> AnyView {
//
//        FestivalMapView(viewModel: viewModel)
//            .toAnyView()
//
//    }

}
