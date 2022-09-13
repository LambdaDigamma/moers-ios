//
//  PersonsList.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import SwiftUI

struct PersonsList: View {
    
    @StateObject var viewModel = PersonsViewModel()
    
    
    var body: some View {
        
        List(viewModel.persons) { person in
            
            NavigationLink {
              
                Text(person.name ?? "")
                
            } label: {
                
                VStack {
                    
                    Text(person.name ?? "")
                    
                    ForEach(person.status ?? [], id: \.self) { status in
                        Text(status)
                    }
                    
                }
                
            }
            
            
        }
        .onAppear {
            Task {
                do {
                    try await viewModel.initIfNeeded()
                    try await viewModel.loadPersons()
                } catch {
                    
                }
            }
        }
        
    }
}

struct PersonsList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PersonsList()
        }
    }
}
