//
//  ParkingTimerActivePartial.swift
//  
//
//  Created by Lennart Fischer on 02.04.22.
//

import SwiftUI
import Core
import CoreLocation

public struct ParkingTimerActivePartial: View {
    
    @ObservedObject var viewModel: ParkingTimerViewModel
    
    private var onCancel: () -> Void
    
    public init(
        viewModel: ParkingTimerViewModel,
        onCancel: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.onCancel = onCancel
    }
    
    private let cornerRadius: Double = 12
    
    public var body: some View {
        
        VStack {
            
            preview()
            
            locationPreview()
            
            Spacer()
            
            actions()
            
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func preview() -> some View {
        
        VStack(spacing: 12) {
            
            HStack {
                Text(Image(systemName: "clock.fill"))
                Text(viewModel.endDate, style: .time)
            }
            .font(.callout)
            .foregroundColor(.yellow)
            
            Text(viewModel.endDate, style: .timer)
                .font(.largeTitle)
                .fontWeight(.bold)
            
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemFill))
        .cornerRadius(cornerRadius)
        
    }
    
    @ViewBuilder
    private func locationPreview() -> some View {
        
        if let coordinate = viewModel.carPosition {
            
            Button(action: {
                let provider = AppleNavigationProvider()
                provider.startNavigation(to: Point(from: coordinate), with: "Dein Auto")
            }) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack {
                        
                        MapSnapshotView(
                            location: coordinate,
                            span: 0.002,
                            annotations: [
                                .init(
                                    coordinate: coordinate,
                                    annotationType: .image(UIImage(systemName: "car.fill")!)
                                )
                            ]
                        )
                        .frame(maxWidth: .infinity)
                        .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack {
                        
                        Text("Zurück zum Auto \(Image(systemName: "chevron.right"))")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                    }
                    .padding()
                    
                }
            }
            .background(Color(UIColor.secondarySystemFill))
            .cornerRadius(cornerRadius)
            
        } else {
            EmptyView()
        }
        
    }
    
    @ViewBuilder
    private func actions() -> some View {
        
        HStack {
            
            Button("Beenden", action: {
                onCancel()
                ParkingTimerViewModel.resetCurrent()
            })
                .buttonStyle(SecondaryButtonStyle())
            
        }
        
    }
    
}
