//
//  WeatherDashboardView.swift
//  
//
//  Created by Lennart Fischer on 27.09.22.
//

import Core
import SwiftUI

@available(iOS 16.0, *)
public struct WeatherDashboardView: View {
    
    @StateObject var viewModel = WeatherDashboardViewModel()
    
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
        .onAppear {
            viewModel.load()
        }
        
    }
    
}

@available(iOS 16.0, *)
struct WeatherDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherDashboardView()
            .padding()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
