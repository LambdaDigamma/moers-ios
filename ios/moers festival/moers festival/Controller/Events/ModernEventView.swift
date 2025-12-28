//
//  ModernEventView.swift
//  moers festival
//
//  Created by Lennart Fischer on 23.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import MediaLibraryKit
import MMPages

public struct ModernEventView: View {
    
    @ObservedObject var viewModel: EventDetailViewModel
    @ObservedObject var actionTransmitter: ActionTransmitter
    
    private let showDetails: () -> Void
    
    public init(
        viewModel: EventDetailViewModel,
        actionTransmitter: ActionTransmitter,
        showDetails: @escaping () -> Void = {}
    ) {
        self.viewModel = viewModel
        self.actionTransmitter = actionTransmitter
        self.showDetails = showDetails
    }
    
    public var body: some View {
        
        ScrollView {

            LazyVStack(spacing: 0) {

                if let header = viewModel.header {

                    GenericMediaView(media: viewModel.header, resizingMode: .aspectFill)
                        .aspectRatio(CGSize(width: header.responsiveWidth ?? 16, height: header.responsiveHeight ?? 9), contentMode: .fill)

                    if let credits = header.credits, !credits.isEmptyOrWhitespace {
                        Text("© \(credits)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemBackground))

                        Divider()
                    }

                }

                metadata()

                if let pageID = viewModel.pageID {
                    IsolatedNativePageView(pageID: pageID)
                        .environmentObject(actionTransmitter)
                        .environment(\.openURL, OpenURLAction { url in
                            actionTransmitter.dispatchOpenURL(url)
                            return .handled
                        })
                }

            }
            .readableContentWidth()

        }
        .task {
            self.viewModel.reload()
        }
        .onDisappear {
            self.viewModel.cancel()
        }
        
    }
    
    @ViewBuilder
    private func metadata() -> some View {
        
        if let event = viewModel.event {
            
            VStack(alignment: .leading) {
                
                if let screenData = viewModel.screenData {
                    
                    Button(action: {
                        showDetails()
                    }) {
                        
                        EventDetailInformationRow(
                            title: event.name,
                            startDate: screenData.startDate,
                            endDate: screenData.endDate,
                            timeDisplayMode: screenData.timeMode,
                            location: viewModel.location?.name,
                            artists: event.artists?.compactMap { $0 } ?? [],
                            isOpenEnd: event.isOpenEnd
                        )
                        
                    }
                    
                    Divider()
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
}
