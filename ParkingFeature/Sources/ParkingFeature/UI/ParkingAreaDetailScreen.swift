//
//  ParkingAreaDetailScreen.swift
//  
//
//  Created by Lennart Fischer on 15.01.22.
//

import SwiftUI
import Core

public struct ParkingAreaDetailScreen: View {
    
    private let viewModel: ParkingAreaViewModel
    
    public init(viewModel: ParkingAreaViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        ScrollView {
            
            header()
                .padding()
            
            availability()
            
            openingHours()
            
            prizeInformation()
            
            actions()
            
        }
        .toolbar {
            toolbar()
        }
        
    }
    
    @ViewBuilder
    private func header() -> some View {
        
        if let location = viewModel.
        
        Map(viewModel)
        
        VStack(alignment: .leading) {
            
            Text(viewModel.title)
            Text("Aktuell geöffnet")
                .foregroundColor(.secondary)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func availability() -> some View {
        
        Divider()
        
        VStack(alignment: .leading) {
            
            HStack {
                
                Text("Freie Parkplätze")
                
                Spacer()
                
                Text("\(viewModel.free)") +
                Text(" / \(viewModel.total)").foregroundColor(.secondary)
                
            }
            
            ProgressMeterView(value: viewModel.percentage, color: .yellow)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func openingHours() -> some View {
        
        Divider()
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text("Öffnungszeiten")
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            HStack {
                
                Text("Mo-Fr")
                
                Spacer()
                
                Text("09:00 - 19:00")
                
            }
            
            HStack {
                
                Text("Sa")
                
                Spacer()
                
                Text("09:00 - 16:00")
                
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func prizeInformation() -> some View {
        
        Divider()
        
        VStack(alignment: .leading) {
            
            Text("Preise")
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            Text("Keine Preisinformationen")
                .foregroundColor(.secondary)
            
        }.padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        VStack {
            
            Button("Navigation starten", action: {})
                .buttonStyle(SecondaryButtonStyle())
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    private func toolbar() -> some ToolbarContent {
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: {}) {
                Image(systemName: "arrow.triangle.turn.up.right.circle")
            }
        }
        
    }
    
}

struct ParkingAreaDetailScreen_Previews: PreviewProvider {
    static var previews: some View {
        ParkingAreaDetailScreen(viewModel: ParkingAreaViewModel(
            title: "Kauzstraße",
            free: 45,
            total: 200,
            currentOpeningState: .open)
        )
            .preferredColorScheme(.dark)
    }
}
