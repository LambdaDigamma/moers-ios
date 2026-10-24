//
//  IsolatedWebView.swift
//  
//
//  Created by Lennart Fischer on 08.05.23.
//

import Foundation
import SwiftUI

#if canImport(WebKit)

public struct IsolatedWebView: View {
    
    @State var viewModel: WebViewStateModel
    
    private let url: URL
    
    public init(url: URL) {
        self.url = url
        self._viewModel = State(initialValue: WebViewStateModel())
    }
    
    public var body: some View {
        
        WebView(url: url, webViewStateModel: viewModel)
        
    }
    
}

#endif
