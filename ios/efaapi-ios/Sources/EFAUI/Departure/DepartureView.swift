//
//  DepartureView.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import SwiftUI
import EFAAPI

#if canImport(UIKit)
import UIKit

struct DepartureView: View {
    
    @ObservedObject var viewModel: DepartureViewModel
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack(spacing: 12) {
                TransportTypeSymbol(transportType: viewModel.transportType)
                Text(viewModel.direction)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            
            HStack(alignment: .top) {
                
                VStack {
                    if let date = viewModel.time {
                        Text("\(date, formatter: DepartureRowView.timeFormatter)")
                    }
                    if let date = viewModel.actual {
                        Text("\(date, formatter: DepartureRowView.timeFormatter)")
                            .foregroundColor(.accentColor)
                    }
                }
                
                VStack(alignment: .leading) {
                    
                    Text(viewModel.description)
                        .font(.caption)
                    
                }
                
                Spacer()
                
            }
            
            HStack {
                
                Text(viewModel.symbol)
                    .font(.callout)
                    .padding(4)
                    .padding(.horizontal, 4)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(6)
                
                if let platform = viewModel.platform {
                    Text("Steig \(platform)")
                        .font(.callout)
                        .padding(4)
                        .padding(.horizontal, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.systemBackground))
    }
    
}

struct DepartureView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let actual = ITDDateTime.stub(date: Date(timeIntervalSinceNow: 60 * 10))
        let departure = ITDDeparture.stub().setting(\.actualDateTime, to: actual)
        let viewModel = DepartureViewModel(departure: departure)
        
        DepartureView(viewModel: viewModel)
            .frame(maxWidth: .infinity)
            .previewLayout(.sizeThatFits)
        
    }
    
}

#endif
