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

}
