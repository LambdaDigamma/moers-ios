//
//  TripConfigurationScreen.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI
import EFAAPI
import Factory

public struct TripConfigurationScreen: View {
    
    @State var showSelectOrigin = false
    @State var showSelectDestination = false
    
    @ObservedObject var viewModel: TripSearchViewModel
    
    private let onSearch: () -> ()
    
    public init(
        viewModel: TripSearchViewModel,
        onSearch: @escaping () -> () = {}
    ) {
        self.viewModel = viewModel
        self.onSearch = onSearch
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVStack {
                
//                Text("Fahrt planen")
//                    .font(.largeTitle)
//                    .fontWeight(.semibold)
                
//                Text("Von")
//                    .padding(.horizontal)
//                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    
                    Button(action: openSelectOrigin) {
                        Text(viewModel.origin?.name ?? "Abfahrt auswählen")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {}) {
                        Text("\(Image(systemName: "mappin.and.ellipse"))")
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: 60)
                    
                }
                
//                Text("Nach")
//                    .padding(.horizontal)
//                    .padding(.top)
//                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    
                    Button(action: openSelectDestination) {
                        Text(viewModel.destination?.name ?? "Ziel auswählen")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(12)
                    }
                    
                    Button(action: { viewModel.swapOriginDestination() }) {
                        Text("\(Image(systemName: "arrow.up.arrow.down"))")
                            .fontWeight(.semibold)
                            .foregroundColor(.yellow)
                            .padding(.horizontal)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(12)
                    }
                    .frame(maxWidth: 60)
                    
                }
                .padding(.bottom)
                
                Button(action: search) {
                    Text("Verbindung suchen")
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemYellow))
                        .cornerRadius(12)
                }
                
//                Spacer()
//                    .frame(idealHeight: 50)
                
                favorites()
                    .padding(.top, 60)
                
                disclaimer()
                
            }
            .padding()
            
        }
        .navigationTitle(Text("Auskunft"))
        .sheet(isPresented: $showSelectOrigin) {
            NavigationView {
                TransitLocationSearchScreen(
                    transitLocationSearchMode: .departure
                ) { (location: TransitLocation) in
                    self.viewModel.updateOrigin(location)
                }
            }
        }
        .sheet(isPresented: $showSelectDestination) {
            NavigationView {
                TransitLocationSearchScreen(
                    transitLocationSearchMode: .arrival
                ) { (location: TransitLocation) in
                    self.viewModel.updateDestination(location)
                }
            }
        }
        
    }
    
    @ViewBuilder
    private func favorites() -> some View {
        
        VStack(spacing: 8) {
            
            HStack {
                
                Text("Favoriten")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                Button(action: {}) {
                    Text("Alle \(Image(systemName: "chevron.right"))")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.yellow)
                
            }.padding(.horizontal)
            
            favoriteRow(
                title: "Zur Arbeit",
                origin: "Moers",
                destination: "Aachen",
                accentColor: .red,
                systemImageName: "bag"
            )
            
            favoriteRow(
                title: "Nach Hause",
                origin: "Aachen",
                destination: "Moers"
            )
            
        }
        
    }
    
    @ViewBuilder
    private func disclaimer() -> some View {
        
        VStack(alignment: .leading) {
            
            Text("Du kannst keine Tickets über diese App kaufen, da es keine Möglichkeit der Integration gibt.")
                .font(.caption)
                .foregroundColor(.secondary)
            
        }
        .padding(.top)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func favoriteRow(
        title: String,
        origin: String,
        destination: String,
        accentColor: Color = .yellow,
        onAccentColor: Color = .black,
        systemImageName: String = "house"
    ) -> some View {
        
        HStack(spacing: 16) {
            
            Circle()
                .fill(accentColor)
                .aspectRatio(1, contentMode: .fit)
                .frame(maxHeight: 50)
                .overlay(ZStack {
                    Image(systemName: systemImageName)
                        .foregroundColor(onAccentColor)
                })
                
            VStack(alignment: .leading, spacing: 4) {
                
                Text(title)
                    .foregroundColor(.primary)
                    .fontWeight(.semibold)
                
                Text("\(origin) \(Image(systemName: "arrow.right")) \(destination)")
                    .foregroundColor(.secondary)
                    .font(.caption)
                
            }
            
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 8)
//        .background(Color.yellow.opacity(0.3))
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(12)
        
    }
    
    // MARK: - Actions -
    
    private func openSelectOrigin() {
        
        showSelectOrigin = true
        
    }
    
    private func openSelectDestination() {
        
        showSelectDestination = true
        
    }
    
    private func search() {
        
        viewModel.onSearchEvent?()
        
    }
    
}

struct TripConfigurationScreen_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let loader = DefaultTransitService.defaultLoader()
        let service = DefaultTransitService(loader: loader)
        let viewModel = TripSearchViewModel(transitService: service)
        
        Container.shared.transitService.register { service }
        
        return NavigationView {
            TripConfigurationScreen(
                viewModel: viewModel
            )
        }.preferredColorScheme(.dark)
    }
    
}
