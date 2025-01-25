//
//  NativePageView.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import SwiftUI

// <TopContent: View, BottomContent: View>
public struct NativePageView: View {
    
    @ObservedObject var viewModel: NativePageViewModel
    @ObservedObject var actionTransmitter: ActionTransmitter
    
//    var topContent: (DataState<Page, Error>) -> TopContent
//    var bottomContent: (DataState<Page, Error>) -> BottomContent
    
    public init(
        viewModel: NativePageViewModel,
        actionTransmitter: ActionTransmitter
//        @ViewBuilder top: @escaping (DataState<Page, Error>) -> TopContent,
//        @ViewBuilder bottom: @escaping (DataState<Page, Error>) -> BottomContent
    ) {
        self.viewModel = viewModel
        self.actionTransmitter = actionTransmitter
//        self.topContent = top
//        self.bottomContent = bottom
    }
    
    public var body: some View {
        
        ZStack {
            
            viewModel.state.isLoading {
                loading()
                    .frame(minHeight: 80)
            }
            
            viewModel.state.hasResource { (page: Page) in
                success(page: page)
            }
            
            viewModel.state.hasError { (error: Error) in
                
                Text(error.localizedDescription)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .environmentObject(actionTransmitter)
        .task {
            viewModel.reload()
        }
        .onDisappear {
            viewModel.cancel()
        }
        
    }
    
    @ViewBuilder func loading() -> some View {
        
        ProgressView()
            .progressViewStyle(.circular)
        
    }
    
    @ViewBuilder func success(page: Page) -> some View {
        
        NativePageContentRenderer(blocks: page.blocks, frame: .zero)
        
    }
    
}
