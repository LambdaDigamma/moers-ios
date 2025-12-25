//
//  TripExperienceViewController.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import UIKit
import SwiftUI
import Combine

public class TripExperienceViewController: UIHostingController<ActiveTripScreen> {
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    public var onCancel: (() -> Void)?
    
    public init() {
        super.init(rootView: ActiveTripScreen())
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    private func setupUI() {
        
        self.title = "Details"
        self.view.backgroundColor = .systemBackground
        
        NotificationCenter.default
            .publisher(for: .deactivatedTrip)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.onCancel?()
            }
            .store(in: &cancellables)
        
    }
    
}
