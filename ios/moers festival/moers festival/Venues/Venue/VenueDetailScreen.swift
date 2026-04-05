//
//  LocationDetailScreen.swift
//  moers festival
//
//  Created by Lennart Fischer on 06.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Core
import SwiftUI
import MMEvents
import MMPages
import MapKit

public struct VenueDetailScreen: View {
    
    @ObservedObject var viewModel: VenueDetailViewModel
    @State private var isPageExpanded = false
    
    public let onSelectEvent: (Event.ID) -> Void
    private let presentationContext: VenueDetailPresentationContext
    private let actionTransmitter: ActionTransmitter
    
    public init(
        viewModel: VenueDetailViewModel,
        presentationContext: VenueDetailPresentationContext = .phoneFullScreen,
        actionTransmitter: ActionTransmitter,
        onSelectEvent: @escaping (Event.ID) -> Void
    ) {
        self.viewModel = viewModel
        self.presentationContext = presentationContext
        self.actionTransmitter = actionTransmitter
        self.onSelectEvent = onSelectEvent
    }
    
    public var body: some View {
        Group {
            switch presentationContext {
                case .phoneFullScreen:
                    phoneLayout()
                case .ipadDetail:
                    ipadLayout()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(presentationContext == .ipadDetail ? Color.clear : Color(UIColor.systemBackground))
        
    }
    
    private func phoneLayout() -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                hero(height: 250, cornerRadius: 0)
                    .preferredColorScheme(.light)
                
                header()
                
                if hasNavigationPoint {
                    navigation()
                }
                
                page()
                
                events(
                    topPadding: 32,
                    sectionBackground: Color(UIColor.secondarySystemBackground)
                )
                .padding(.top, 16)
            }
        }
    }
    
    private func ipadLayout() -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                hero(height: 208, cornerRadius: 24)
                
                ipadSummary()
                
                if !viewModel.events.isEmpty {
                    sectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Programm")
                                .font(.headline)
                            
                            events(topPadding: 0, sectionBackground: .clear)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                if viewModel.pageID != nil {
                    sectionCard {
                        DisclosureGroup(
                            isExpanded: $isPageExpanded,
                            content: {
                                page()
                                    .padding(.top, 12)
                            },
                            label: {
                                Label("More information", systemImage: "text.alignleft")
                                    .font(.headline)
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Color.clear)
    }
    
    @ViewBuilder
    private func hero(height: CGFloat, cornerRadius: CGFloat) -> some View {
        if let point = viewModel.point, point.latitude != 0, point.longitude != 0 {
            VenueHeroPreview(
                mapItem: viewModel.mapItem,
                point: point
            )
            .frame(height: height)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(alignment: .bottomLeading) {
                heroOverlay()
            }
        }
    }
    
    private func mapSnapshot(point: Point) -> some View {
        MapSnapshotView(
            location: point.toCoordinate(),
            span: 0.001,
            annotations: [SnapshotAnnotation(point: point)],
            poiFilter: .excludingAll
        )
    }
    
    @ViewBuilder
    private func heroOverlay() -> some View {
        if presentationContext == .ipadDetail {
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                if let addressSummary {
                    Text(addressSummary)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.88))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.75),
                        Color.black.opacity(0.05)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
    }
    
    @ViewBuilder
    private func ipadSummary() -> some View {
        sectionCard {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(viewModel.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        if let addressLine1 = viewModel.addressLine1, !addressLine1.isEmpty {
                            Text(addressLine1)
                        }
                        
                        if let addressLine2 = viewModel.addressLine2, !addressLine2.isEmpty {
                            Text(addressLine2)
                        }
                    }
                    .foregroundColor(.secondary)
                }
                
                if hasNavigationPoint {
                    navigation()
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func sectionCard<Content: View>(
        @ViewBuilder content: () -> Content
    ) -> some View {
        content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.08))
            }
    }
    
    private var hasNavigationPoint: Bool {
        if let point = viewModel.point {
            return point.latitude != 0 && point.longitude != 0
        }
        
        return false
    }
    
    private var addressSummary: String? {
        [viewModel.addressLine1, viewModel.addressLine2]
            .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
            .nilIfEmpty
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(viewModel.name)
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading) {
                
                Text(viewModel.subtitle)
                    .foregroundColor(.secondary)
                
                if let addressLine2 = viewModel.addressLine2 {
                    Text(addressLine2)
                }
                
            }
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding()
        
    }
    
    @ViewBuilder
    private func page() -> some View {
        
        if let pageID = viewModel.pageID {
            
            IsolatedNativePageView(pageID: pageID)
                .environmentObject(actionTransmitter)
                .environment(\.openURL, OpenURLAction { url in
                    actionTransmitter.dispatchOpenURL(url)
                    return .handled
                })
            
        }
        
    }
    
    @ViewBuilder
    private func navigation() -> some View {
        
        if let point = viewModel.point {
            
            AutoCalculatingDirectionsButton(
                coordinate: point.toCoordinate(),
                directionsMode: .walking,
                action: {
                    AppleNavigationProvider().startNavigation(to: point, withName: viewModel.name)
                }
            )
            .padding(.horizontal, presentationContext == .ipadDetail ? 0 : 16)
            
        }
        
    }
    
    private func events(
        topPadding: CGFloat,
        sectionBackground: Color
    ) -> some View {
        GroupedEventCollection(
            viewModels: viewModel.events,
            containerBackground: sectionBackground,
            onSelectEvent: { (eventID: Event.ID) in
                self.onSelectEvent(eventID)
            }
        )
        .padding(.top, topPadding)
    }
    
}

struct VenueDetailScreen_Previews: PreviewProvider {
    
    static let viewModel: VenueDetailViewModel = {
        let viewModel = VenueDetailViewModel(placeID: 1)
        viewModel.name = "Festivalhalle"
        viewModel.subtitle = "Filderstraße 142"
        viewModel.point = Point(latitude: 51.440105, longitude: 6.619091)
        return viewModel
    }()
    
    static var previews: some View {
        
        NavigationView {
            
            VenueDetailScreen(
                viewModel: viewModel,
                presentationContext: .phoneFullScreen,
                actionTransmitter: ActionTransmitter(),
                onSelectEvent: { _ in }
            )
            
        }
        .preferredColorScheme(.light)
        
    }
    
}

@available(iOS 16.0, *)
private struct VenueHeroPreviewContent: View {
    
    let mapItem: MKMapItem?
    let point: Point
    
    @State private var lookAroundScene: MKLookAroundScene?
    
    var body: some View {
        Group {
            if let lookAroundScene {
                VenueLookAroundPreview(scene: lookAroundScene)
            } else {
                MapSnapshotView(
                    location: point.toCoordinate(),
                    span: 0.001,
                    annotations: [SnapshotAnnotation(point: point)],
                    poiFilter: .excludingAll
                )
            }
        }
        .task(id: taskID) {
            await loadLookAroundScene()
        }
    }
    
    private var taskID: String {
        [
            mapItem?.name ?? "",
            "\(point.latitude)",
            "\(point.longitude)"
        ].joined(separator: "|")
    }
    
    private func loadLookAroundScene() async {
        let request: MKLookAroundSceneRequest
        
        if let mapItem {
            request = MKLookAroundSceneRequest(mapItem: mapItem)
        } else {
            request = MKLookAroundSceneRequest(coordinate: point.toCoordinate())
        }
        
        do {
            lookAroundScene = try await request.scene
        } catch {
            lookAroundScene = nil
        }
    }
}

private struct VenueHeroPreview: View {
    
    let mapItem: MKMapItem?
    let point: Point
    
    var body: some View {
        if #available(iOS 16.0, *) {
            VenueHeroPreviewContent(mapItem: mapItem, point: point)
        } else {
            MapSnapshotView(
                location: point.toCoordinate(),
                span: 0.001,
                annotations: [SnapshotAnnotation(point: point)],
                poiFilter: .excludingAll
            )
        }
    }
}

@available(iOS 16.0, *)
private struct VenueLookAroundPreview: UIViewControllerRepresentable {
    
    let scene: MKLookAroundScene
    
    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        let controller = MKLookAroundViewController(scene: scene)
        controller.isNavigationEnabled = false
//        controller.isStreetNamesEnabled = true
        controller.badgePosition = .topTrailing
        return controller
    }
    
    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {
        uiViewController.scene = scene
    }
}

private extension String {
    var nilIfEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
