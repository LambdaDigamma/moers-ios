//
//  DebugFCMTokenVisibility.swift
//  moers festival
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import Foundation

nonisolated struct DebugFCMTokenVisibility {

    static var isVisible: Bool {
        #if DEBUG
        return true
        #else
        return isTestFlightReceipt(Bundle.main.appStoreReceiptURL)
        #endif
    }

    static func isVisible(isDebugBuild: Bool, receiptURL: URL?) -> Bool {
        return isDebugBuild || isTestFlightReceipt(receiptURL)
    }

    static func isTestFlightReceipt(_ receiptURL: URL?) -> Bool {
        return receiptURL?.lastPathComponent == "sandboxReceipt"
    }

}
