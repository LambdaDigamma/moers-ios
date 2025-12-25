//
//  ScanStationViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 14.01.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import SwiftUI

class ScanStationViewController: UIViewController {

//    weak var coordinator: TourCoordinator?
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
//        coordinator = nil
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        let scannerView = ScanStationView(scannedQRCode: showPage)
        
        self.addSubSwiftUIView(scannerView, to: view)
        
        self.navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelScan))
        ]
        
//        self.title = String.localized("ScanStationTitle")
        
    }
    
    // MARK: - Actions
    
    @objc private func showPage(url: String) {
        
        do {
//            try self.coordinator?.showQRCodePage(url: url, sender: self)
        } catch {
            print(error) // TODO: Show Alert
        }
        
    }
    
    @objc private func cancelScan() {
//        coordinator?.closeScanner()
    }
    
}
