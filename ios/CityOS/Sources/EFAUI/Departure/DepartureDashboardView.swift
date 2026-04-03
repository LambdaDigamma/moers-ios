//
//  DepartureDashboardView.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import SwiftUI
import EFAAPI
import Factory
import Combine

public struct DepartureDashboardData {
    
    public let stationName: String
    public let departures: [DepartureViewModel]
    
}

public class DashboardDepartureViewModel: ObservableObject {
    
    @Published var data: DataState<DepartureDashboardData, Error> = .loading
    
    @Injected(\.transitService) private var transitService
    
    public func load() async {
        
        do {
            let data = try await transitService.departureMonitor(id: 20016032)
            self.data = .success(.init(
                stationName: data.name,
                departures: data.departures
            ))
        } catch {
            self.data = .error(error)
        }
        
    }
    
}

public struct DepartureDashboardView: View {
    
    @StateObject var viewModel: DashboardDepartureViewModel = .init()
    
    public init() {
        
    }
    
    public var body: some View {
        
        ZStack {
            
            viewModel.data.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
                    .padding(.vertical, 80)
            }
            
            viewModel.data.hasError { (error: Error) in
                Text(error.localizedDescription)
                    
            }
            
            viewModel.data.hasResource { (data: DepartureDashboardData) in
                DepartureMonitorView(
                    viewModel: .init(
                        stationName: data.stationName,
                        departures: data.departures
                    ),
                    showBackground: false
                )
            }
            
        }
        .frame(maxWidth: .infinity)
        .task {
            await viewModel.load()
        }
        
    }
    
}

struct DepartureDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DepartureDashboardView()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
