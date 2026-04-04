//
//  RegionSwitchScreen.swift
//  
//
//  Created by Lennart Fischer on 18.04.22.
//

import SwiftUI
import CoreLocation

struct RegionSwitchScreen: View {
    
    var body: some View {
        
        VStack {
            
            ScrollView {
                
                VStack(spacing: 20) {
                    
//                    Text("Region erkannt")
//                        .font(.title)
//                        .fontWeight(.semibold)
                    
//                    Spacer()
//                        .frame(height: 200)
                    
                    regionDetails()
                    
                    infoText()
                        .padding()
                    
//                    Spacer()
                    
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            
            bottomActions()
            
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(String(localized: "Region detected", bundle: .module))
        
    }
    
    @ViewBuilder
    private func infoText() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text(String(localized: "It looks like you have arrived in another city that is also supported by Transparencity.", bundle: .module))
                .foregroundColor(.secondary)
            
            Text(String(localized: "Changing the region will not affect any settings from your other regions.", bundle: .module))
            
            Text(String(localized: "You can also change this manually later.", bundle: .module))
            
        }
        .foregroundColor(.secondary)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func regionDetails() -> some View {
        
        VStack(spacing: 0) {
            
            // Map
            
            let coordinate = CLLocationCoordinate2D(latitude: 51.459167, longitude: 6.619722)
            
            MapSnapshotView(
                location: coordinate,
                span: 0.1
//                annotations: [
//                    .init(
//                        coordinate: coordinate,
//                        annotationType: .image(UIImage(systemName: "car.fill")!)
//                    )
//                ]
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            
            VStack(spacing: 12) {
                
                HStack {
                    
                    Text(String(localized: "City", bundle: .module))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Moers")
                        .fontWeight(.semibold)
                    
                }
                
                Divider()
                    .padding(.leading, 0)
                
                HStack {
                    
                    Text(String(localized: "Provider", bundle: .module))
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("Code for Niederrhein e.V.")
                        .fontWeight(.semibold)
                    
                }
                
                Divider()
                    .padding(.leading, 0)
                
                supportedFeatures()
                
            }
            .font(.callout)
            .padding(.horizontal)
            .padding(.vertical)
            
        }
        .background(Color(UIColor.secondarySystemBackground))
//        .cornerRadius(12)
        
    }
    
    @ViewBuilder
    private func supportedFeatures() -> some View {
        
        HStack(alignment: .top) {
            
            Text(String(localized: "Features", bundle: .module))
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Spacer()
            
            HStack() {
                
                Spacer()
                
                FeatureIcon.parking()
                FeatureIcon.rubbish()
                FeatureIcon.locations()
                
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            //                    .background(Color.red)
            
        }
        
    }
    
    @ViewBuilder
    private func bottomActions() -> some View {
        
        VStack(spacing: 16) {
            
            Button(action: {}) {
                Text(String(localized: "Switch region", bundle: .module))
//                    .fontWeight(.semibold)
//                    .frame(maxWidth: .infinity, alignment: .center)
//                    .padding()
//                    .background(Color.black)
//                    .foregroundColor(.white)
//                    .cornerRadius(12)
            }
            .buttonStyle(PrimaryButtonStyle())
            
            Button(action: {}) {
                Text(String(localized: "Later", bundle: .module))
                    .fontWeight(.medium)
                    .foregroundColor(.yellow)
            }
            
        }
        .frame(maxWidth: .infinity)
        .padding()
        
    }
    
}

struct FeatureIcon: View {
    
    let backgroundFill: Color
    let foreground: Color
    let systemName: String
    
    var body: some View {
        Circle()
            .fill(backgroundFill)
            .overlay(ZStack {
                Image(systemName: systemName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.white)
            }.padding(6))
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 24, height: 24)
    }
    
    static func parking() -> some View {
        FeatureIcon(
            backgroundFill: Color.blue,
            foreground: Color.white,
            systemName: "parkingsign"
        )
    }
    
    static func rubbish() -> some View {
        FeatureIcon(
            backgroundFill: Color.green,
            foreground: Color.white,
            systemName: "trash.fill"
        )
    }
    
    static func locations() -> some View {
        FeatureIcon(
            backgroundFill: Color.red,
            foreground: Color.white,
            systemName: "mappin"
        )
    }
    
}

struct RegionSwitchScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegionSwitchScreen()
        }
        .preferredColorScheme(.dark)
    }
}
