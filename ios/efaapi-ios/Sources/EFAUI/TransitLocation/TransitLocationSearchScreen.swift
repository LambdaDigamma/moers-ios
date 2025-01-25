//
//  TransitLocationSearchView.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import SwiftUI
import EFAAPI
import Factory

public enum TransitLocationSearchMode: String, Hashable {
    
    case departure
    case arrival
    case via
    case general
    
    public var short: String {
        
        switch self {
            case .departure:
                return "Von"
            case .arrival:
                return "Nach"
            case .via:
                return "Via"
            case .general:
                return ""
        }
        
    }
    
    public var title: String {
        
        switch self {
            case .departure:
                return "Abfahrt suchen"
            case .arrival:
                return "Ziel suchen"
            case .via:
                return "Zwischenstop suchen"
            case .general:
                return "Stop suchen"
        }
        
    }
    
}

#if canImport(UIKit)

public struct TransitLocationSearchScreen: View {
    
    @Environment(\.presentationMode) var presentationMode
    @StateObject var viewModel: TransitLocationSearchViewModel
    
    private let transitLocationSearchMode: TransitLocationSearchMode
    private let onSelectTransitStation: (TransitLocation) -> Void
    
    public init(
        transitLocationSearchMode: TransitLocationSearchMode = .general,
        onSelectTransitStation: @escaping (TransitLocation) -> Void = { _ in }
    ) {
        self._viewModel = .init(
            wrappedValue: TransitLocationSearchViewModel(service: Container.shared.transitService())
        )
        self.transitLocationSearchMode = transitLocationSearchMode
        self.onSelectTransitStation = onSelectTransitStation
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            search()
            Divider()
            list()
        }
        .background(Color(UIColor.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(Text(transitLocationSearchMode.title))
        .onAppear {
            self.viewModel.loadRecentSearches()
        }
        
    }
    
    @ViewBuilder
    private func search() -> some View {
        
        VStack {
            
//            Text("\(transitLocationSearchMode.title)")
//                .font(.title3)
//                .fontWeight(.semibold)
//                .foregroundColor(.primary)
            
            HStack {
                
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .opacity(0.7)
                
                TextField("Wähle einen Punkt…", text: $viewModel.searchTerm)
                    .textContentType(UITextContentType.location)
                    .textFieldStyle(.plain)
                
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
            
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func list() -> some View {
        
        ScrollView {
            
            VStack {
                
                if viewModel.searchActive {
                    
                    ForEach(viewModel.transitLocations, id: \.self) { location in
                        
                        Button(action: {
                            self.viewModel.addNewRecentSearch(transitLocation: location)
                            self.onSelectTransitStation(location)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            
                            TransitLocationRow(transitLocation: location)
                                .background(Color(UIColor.secondarySystemBackground))
                                .frame(maxWidth: .infinity)
                                .cornerRadius(16)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    
                } else {
                    
                    ForEach(viewModel.recentSearches, id: \.self) { location in
                        
                        Button(action: {
                            self.onSelectTransitStation(location)
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            
                            TransitLocationRow(transitLocation: location)
                                .background(Color(UIColor.secondarySystemBackground))
                                .frame(maxWidth: .infinity)
                                .cornerRadius(16)
                            
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                    }
                    
                }
                
            }
            .padding()
            
        }
        
    }
    
}

struct TransitLocationSearchView_Previews: PreviewProvider {
    
    static let service: DefaultTransitService = {
        
        let loader = DefaultTransitService.defaultLoader()
        let mockService = StaticTransitService()
        mockService.loadStations = {
            return [.init(name: "Hallo", description: "Test")]
        }
        let service = DefaultTransitService(loader: loader)
        
        return service
        
    }()
    
    @State static var stationID: Stop.ID?
    @State static var showAlert: Bool = false
    
    static var previews: some View {
        
        let _ = Container.shared.transitService.register { service }
        
        NavigationView {
            
            TransitLocationSearchScreen(
                transitLocationSearchMode: .arrival,
                onSelectTransitStation: onSelectTransitLocation(_:)
            )
            .alert(isPresented: $showAlert, content: {
                Alert(
                    title: Text("Title")
                )
            })
            
        }
        .preferredColorScheme(.light)
        
    }
    
    static func onSelectTransitLocation(_ location: TransitLocation) {
        Self.$stationID.wrappedValue = location.stationID
        Self.$showAlert.wrappedValue = true
    }
    
}

#endif
