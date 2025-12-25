//
//  TourOverviewView.swift
//  moers festival
//
//  Created by Lennart Fischer on 01.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import SwiftUI
import MMCommon

public struct TourOverviewView: View {
    
    var showProgress: () -> Void
    var showMap: () -> Void
    var showQRCodeScanner: () -> Void
    
    public init(showProgress: @escaping () -> Void, showMap: @escaping () -> Void, showQRCodeScanner: @escaping () -> Void) {
        self.showProgress = showProgress
        self.showMap = showMap
        self.showQRCodeScanner = showQRCodeScanner
    }
    
    public var body: some View {
        
        ScrollView {

            LazyVStack(spacing: 20) {

                ProgressTourCardView()
                
                MapTourCardView()
                    .onTapGesture {
                        showMap()
                    }
                
                Button("QR Code scannen") {
                    
                    showQRCodeScanner()
                    
                }.buttonStyle(ScanQRCodeButtonStyle())
                
//                ScanQRCodeButton()
                
                
                StationListCardView()

            }
            .padding()

        }
    }
}

struct TourOverviewView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TourOverviewView(showProgress: {},
                             showMap: {},
                             showQRCodeScanner: {})
                .background(Color.systemBackground)
                .navigationTitle("Exhibition")
        }.environment(\.colorScheme, .dark)
    }
}
