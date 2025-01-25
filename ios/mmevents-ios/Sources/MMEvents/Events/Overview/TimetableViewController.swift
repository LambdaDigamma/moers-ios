//
//  TimetableViewController.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import UIKit
import Combine
import SwiftUI

public class TimetableViewController: UIHostingController<AnyView> {
    
    private let transmitter: TimetableTransmitter
    
    private var cancellables = Set<AnyCancellable>()
    
    public var onShowEvent: ((Event.ID) -> Void)?
    
    public init() {
        self.transmitter = TimetableTransmitter()
        super.init(rootView: TimetableScreen().environmentObject(transmitter).toAnyView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTransmitter()
    }
    
    private func setupUI() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        
    }
    
    private func setupTransmitter() {
        
        self.transmitter.showEvent.sink { (eventID: Event.ID) in
            self.onShowEvent?(eventID)
        }
        .store(in: &cancellables)
        
    }
    
}
