//
//  StandardViewModel.swift
//  
//
//  Created by Lennart Fischer on 24.09.21.
//

import Foundation
import Combine
import SwiftUI

@MainActor
@Observable
open class StandardViewModel {

    @ObservationIgnored
    open var cancellables = Set<AnyCancellable>()

    public init() {}

    // ARC releases subscriptions without actor state access. Avoid the inferred
    // isolated destructor, which crashes in older Swift runtimes (swift#88036).
    nonisolated deinit {}

}
