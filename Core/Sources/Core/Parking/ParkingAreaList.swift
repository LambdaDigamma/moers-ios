//
//  ParkingAreaList.swift
//  
//
//  Created by Lennart Fischer on 14.01.22.
//

import SwiftUI

public struct ParkingAreaList: View {
    
    @State private var filter: ParkingAreaFilterType = .all
    
    let gridSpacing: CGFloat = 16
    
    private let viewModels: [ParkingAreaViewModel]
    
    public init() {
        
        self.viewModels = [
            .init(title: "Kauzstr.", free: 51, total: 62),
            .init(title: "Bankstr.", free: 137, total: 139),
            .init(title: "Kastell", free: 76, total: 200),
            .init(title: "Mühlenstr.", free: 709, total: 709),
        ]
        
    }
    
    var columns: [GridItem] {
        return [
            .init(
                .flexible(minimum: 50, maximum: 400),
                spacing: gridSpacing
             ),
            .init(
                .flexible(minimum: 50, maximum: 400),
                spacing: gridSpacing
            ),
        ]
    }
    
    public var body: some View {
        
        ScrollView {
            
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                
                ForEach(viewModels) { viewModel in
                    
                    ParkingAreaDetail(viewModel: viewModel)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(16)
                    
                }
                
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Alle Angaben ohne Gewähr. Die aktuelle Parksituation kann von den gezeigten Daten abweichen.")
                
                Text("Datenquelle: Parkleitsystem der Stadt Moers")
                
            }
            .font(.caption)
            .frame(maxWidth: .infinity)
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .padding()
            
        }
        .navigationTitle(Text("Parkplätze"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Menu {
                    
                    Picker(selection: $filter, label: Text("Filter")) {
                        
                        ForEach(ParkingAreaFilterType.allCases, id: \.self) { filter in
                            Text(filter.title)
                        }
                        
                    }
                    
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                }
                
            }
            
        }
    }
    
}

enum ParkingAreaFilterType: Int, CaseIterable {
    
    case all
    case onlyOpen
    
    var title: String {
        switch self {
            case .all:
                return "Alle"
            case .onlyOpen:
                return "Nur geöffnete"
        }
    }
}

struct ParkingAreaList_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            ParkingAreaList()
                .preferredColorScheme(.dark)
        }
        
    }
}
