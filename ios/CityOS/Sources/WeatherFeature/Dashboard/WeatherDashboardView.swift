//
//  WeatherDashboardView.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import Core
import SwiftUI

public struct WeatherDashboardView: View {
    
    @State var viewModel = WeatherDashboardViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        
        CardPanelView {
            
            viewModel.data.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
            }
            
            viewModel.data.hasError { (error: Error) in
                Text(error.localizedDescription)
                    .padding()
            }
            
            viewModel.data.hasResource { (data: WeatherDashboardData) in
                VStack {
                    Text("23°C")
                        .font(.largeTitle.weight(.semibold))
                }
                .padding()
            }
            
        }
        .task {
            await viewModel.load()
        }
        
    }
    
}

struct WeatherDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherDashboardView()
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
