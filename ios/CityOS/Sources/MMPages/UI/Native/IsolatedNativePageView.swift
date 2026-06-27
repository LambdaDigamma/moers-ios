//
//  IsolatedNativePageView.swift
//  
//
//  Created by Lennart Fischer on 10.04.23.
//

import Foundation
import SwiftUI

public struct IsolatedNativePageView: View {
    
    @State var viewModel: NativePageViewModel
    @Environment(ActionTransmitter.self) var actionTransmitter: ActionTransmitter
    
    public init(pageID: Page.ID) {
        self._viewModel = State(initialValue: NativePageViewModel(pageID: pageID))
    }
    
    public var body: some View {
        
        NativePageView(viewModel: viewModel, actionTransmitter: actionTransmitter)
        
    }
    
}
