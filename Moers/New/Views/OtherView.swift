//
//  OtherView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct OtherView: View {
    var body: some View {
        List {
            
            Section {
                NavigationLink(destination: OrganisationList()) {
                    Text("Organisationen")
                }
            }
            
        }.navigationBarTitle("Other")
    }
}

@available(iOS 13.0, *)
struct OtherView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OtherView()
        }
    }
}
