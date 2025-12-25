//
//  NavigationDirectionsView.swift
//  
//
//  Created by Lennart Fischer on 26.12.22.
//

import UIKit
import SwiftUI
import MapKit
import Core

public struct NavigationDirectionsData {
    
    public let source: Point
    public let destination: Point
    
    public init(source: Point, destination: Point) {
        self.source = source
        self.destination = destination
    }
    
}

public struct NavigationStepData: Identifiable {
    
    public let id: UUID = .init()
    
    public let instruction: String
    
}

public struct NavigationDirectionsView: View {
    
    @StateObject public var viewModel: NavigationViewModel
    
    public init(data: NavigationDirectionsData) {
        self._viewModel = StateObject(
            wrappedValue: NavigationViewModel(
                source: data.source,
                destination: data.destination
            )
        )
    }
    
    public var body: some View {
        
        VStack {
            
            VStack {
                
                viewModel.directions.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
                
                viewModel.directions.hasResource { (response: MKDirections.Response) in
                    if let first = response.routes.first {
                        
                        let steps = first.steps.map { (step: MKRoute.Step) in
                            return NavigationStepData(
                                instruction: step.instructions
                            )
                        }
                        
                        TabView {
                            
                            ForEach(steps) { step in
                                VStack {
                                    Text(step.instruction)
                                        .fontWeight(.medium)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                            }
                            
                        }
//                        .background(Color.red)
                        .frame(maxHeight: 140, alignment: .topLeading)
                        .tabViewStyle(.page)
                        
                    }
                }
                
            }
            
            NavigationDirectionsMapView(viewModel: viewModel)
                .overlay(alignment: .topLeading) {
                    HeadingView()
                        .padding()
                }
            
        }
        
    }
    
}

struct NavigationDirectionsView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationDirectionsView(data: .init(
            source: Point(latitude: 51.45208, longitude: 6.62323),
            destination: Point(latitude: 51.45081, longitude: 6.64163)
        ))
        .preferredColorScheme(.dark)
    }
    
}
