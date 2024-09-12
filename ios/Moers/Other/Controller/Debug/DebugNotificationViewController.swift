//
//  DebugNotificationViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 24.09.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import UIKit
import SwiftUI
import Core

class DebugNotificationViewController: UIViewController {

    private let radioService: RadioService = RadioService.shared
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    private func setupUI() {
        
        let broadcast = RadioBroadcast(id: 1, uid: UUID().uuidString, title: "Was ist los im Kreis Wesel")
        
        let debugView = DebugNotificationView(sendBroadcastNotification: {
            self.radioService.sendTestNotification(for: broadcast, in: 10)
        })
        
        self.addSubView(debugView, to: view)
        
    }

}

struct DebugNotificationView: View {
    
    var sendBroadcastNotification: () -> Void
    
    init(
        sendBroadcastNotification: @escaping () -> Void
    ) {
        self.sendBroadcastNotification = sendBroadcastNotification
    }
    
    var body: some View {
        
        VStack {
            Button(action: sendBroadcastNotification) {
                Text("Sendung")
            }
        }
        
    }
    
}
