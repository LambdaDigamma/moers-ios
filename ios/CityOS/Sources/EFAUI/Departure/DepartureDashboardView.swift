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
    
    private var cancellables: Set<AnyCancellable> = .init()
    
    @Injected(\.transitService) private var transitService
    
    public func load() {
        
        transitService.departureMonitor(id: 20016032)
            .sink { (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        self.data = .error(error)
                    default: break
                }
                
            } receiveValue: { (data: DepartureMonitorData) in
                self.data = .success(.init(
                    stationName: data.name,
                    departures: data.departures
                ))
            }
            .store(in: &cancellables)
        
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
            viewModel.load()
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
