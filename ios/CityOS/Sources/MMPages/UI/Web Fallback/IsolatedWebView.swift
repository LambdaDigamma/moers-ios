//
//  IsolatedWebView.swift
//  
//
//  Created by Lennart Fischer on 08.05.23.
//

import Foundation
import SwiftUI

public struct IsolatedWebView: View {
    
    @StateObject var viewModel: WebViewStateModel
    
    private let url: URL
    
    public init(url: URL) {
        self.url = url
        self._viewModel = StateObject(wrappedValue: WebViewStateModel())
    }
    
    public var body: some View {
        
        WebView(url: url, webViewStateModel: viewModel)
        
    }
    
}
