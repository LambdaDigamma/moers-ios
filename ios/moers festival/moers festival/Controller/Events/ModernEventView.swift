//
//  ModernEventView.swift
//  moers festival
//
//  Created by Lennart Fischer on 23.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import MediaLibraryKit
import Pages

public struct ModernEventView: View {
    
    var viewModel: EventDetailViewModel
    var actionTransmitter: ActionTransmitter
    
    private let showDetails: () -> Void
    private let updateNavigationTitle: (String?) -> Void
    @State private var contentWidth: CGFloat = 0
    @State private var viewportHeight: CGFloat = 0
    @State private var hasScrolledPastHeader = false

    public init(
        viewModel: EventDetailViewModel,
        actionTransmitter: ActionTransmitter,
        showDetails: @escaping () -> Void = {},
        updateNavigationTitle: @escaping (String?) -> Void = { _ in }
    ) {
        self.viewModel = viewModel
        self.actionTransmitter = actionTransmitter
        self.showDetails = showDetails
        self.updateNavigationTitle = updateNavigationTitle
    }
    
    public var body: some View {
        
        ScrollView {

            VStack(spacing: 0) {

                if let header = viewModel.header {

                    EventDetailHeroView(media: header, contentWidth: contentWidth, viewportHeight: viewportHeight)
                        .onGeometryChange(for: Bool.self) { geometry in
                            geometry.frame(in: .named("EventDetail.Scroll")).maxY <= 0
                        } action: { hasPassed in
                            hasScrolledPastHeader = hasPassed
                        }

                    if let credits = header.credits, !credits.isEmptyOrWhitespace {
                        Text("© \(credits)")
                            .foregroundColor(.secondary)
                            .font(.caption)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.systemBackground))
                            .readableContentWidth(includeLayoutMargins: false)
                    }

                }

                metadata()
                    .readableContentWidth(includeLayoutMargins: false)

                if let pageID = viewModel.pageID {
                    IsolatedNativePageView(pageID: pageID)
                        .environment(actionTransmitter)
                        .environment(\.openURL, OpenURLAction { url in
                            actionTransmitter.dispatchOpenURL(url)
                            return .handled
                        })
                        .readableContentWidth(includeLayoutMargins: false)
                }

            }
            .frame(maxWidth: .infinity)
            .onGeometryChange(for: CGFloat.self) { geometry in
                geometry.size.width
            } action: { width in
                contentWidth = width
            }

        }
        .coordinateSpace(name: "EventDetail.Scroll")
        .scrollBounceBehavior(viewModel.header == nil ? .automatic : .always, axes: .vertical)
        .modifier(EventDetailScrollEdgeEffectModifier())
        .onGeometryChange(for: CGFloat.self) { geometry in
            geometry.size.height
        } action: { height in
            viewportHeight = height
        }
        .ignoresSafeArea(.container, edges: artworkSafeAreaEdges)
        .background(Color(uiColor: .systemBackground))
        .onChange(of: navigationTitle, initial: true) { _, title in
            updateNavigationTitle(title)
        }
        .task {
            self.viewModel.reload()
        }
        
    }

    private var showsNavigationTitle: Bool {
        viewModel.header == nil || hasScrolledPastHeader
    }

    private var navigationTitle: String? {
        showsNavigationTitle ? viewModel.event?.name : nil
    }

    private var artworkSafeAreaEdges: Edge.Set {
        if #available(iOS 26, tvOS 26, *), viewModel.header != nil {
            return .top
        }
        return []
    }

    @ViewBuilder
    private func metadata() -> some View {
        
        if let event = viewModel.event {
            
            VStack(alignment: .leading) {
                
                Button(action: {
                    showDetails()
                }) {

                    EventDetailInformationRow(
                        title: event.name,
                        startDate: event.startDate,
                        endDate: event.endDate,
                        scheduleDisplayMode: event.scheduleDisplayMode,
                        location: viewModel.location?.name,
                        artists: event.artists?.compactMap { $0 } ?? [],
                        isOpenEnd: event.isOpenEnd
                    )

                }
                .accessibilityIdentifier("EventDetail.MetadataRow")

                Divider()

            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
}
