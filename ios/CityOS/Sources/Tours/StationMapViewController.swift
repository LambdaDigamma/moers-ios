//
//  StationMapViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit

public class StationMapViewController: UIViewController {

    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.addSubSwiftUIView(StationMapView(), to: view)
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
