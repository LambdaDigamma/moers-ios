//
//  DatabaseInspection.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import Factory
import GRDB
import MMEvents

class DatabaseInspectionViewModel: ObservableObject {
    
    @Injected(\.appDatabase) var database
    
    public func resetDatabase() {
        
        do {
            _ = try database.dbWriter.write { db in
                try EventRecord.deleteAll(db)
            }
        } catch {
            print(error)
        }
        
    }
    
}

struct DatabaseInspection: View {
    
    @StateObject var viewModel = DatabaseInspectionViewModel()
    
    var body: some View {
        
        List {
            SwiftUI.Section {
                Button(action: {}) {
                    Text("Reset database")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .foregroundColor(.red)
                }

            }
        }
        
    }
    
}

struct DatabaseInspection_Previews: PreviewProvider {
    static var previews: some View {
        DatabaseInspection()
            .preferredColorScheme(.dark)
    }
}
