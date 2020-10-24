//
//  OrganisationList.swift
//  Moers
//
//  Created by Lennart Fischer on 20.07.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMAPI

@available(iOS 13.0, *)
struct OrganisationList: View {
    
    @ObservedObject var organisationListViewModel = OrganisationListViewModel()
    
    
    var body: some View {
        
        VStack {
            
            organisationListViewModel.organisations.isLoading() {
                Group  {
                    Spacer()
                    Text("Loading...")
//                    LoadingIndicator(style: .medium)
                    Spacer()
                }
            }
            
            organisationListViewModel.organisations.hasResource { (organisations: [Organisation]) in
                List {
                    ForEach (organisations, id: \.id) { organisation in
                        VStack(alignment: .leading) {
                            Text(organisation.name)
                            Text(organisation.description)
                                .foregroundColor(.secondary)
                                .font(Font.footnote)
                        }
                    }
                }
            }
            
        }
        .navigationBarTitle("Organisations")
        
        
    }
    
    
}

@available(iOS 13.0, *)
struct OrganisationList_Previews: PreviewProvider {
    static var previews: some View {
        OrganisationList(
            organisationListViewModel: OrganisationListViewModel(
                organisationRepository: MockOrganisationRepository()
            )
        )
    }
}
