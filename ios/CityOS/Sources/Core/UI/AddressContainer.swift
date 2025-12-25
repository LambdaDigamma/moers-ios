//
//  AddressContainer.swift
//  
//
//  Created by Lennart Fischer on 13.08.22.
//

import SwiftUI

public struct AddressUiState: Codable {
    
    public var street: String
    public var houseNumber: String
    public var place: String
    public var postcode: String
    
    public init(street: String, houseNumber: String, place: String, postcode: String) {
        self.street = street
        self.houseNumber = houseNumber
        self.place = place
        self.postcode = postcode
    }
    
    public var firstLine: String {
        "\(street) \(houseNumber)"
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public var secondLine: String {
        "\(postcode) \(place)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

public struct AddressContainer: View {
    
    private let address: AddressUiState
    private let label: String?
    
    public init(address: AddressUiState, label: String? = nil) {
        self.address = address
        self.label = label
    }
    
    public var body: some View {
        
        DetailContainer(title: label ?? AppStrings.address) {
            
            if #available(iOS 15.0, *) {
                VStack(alignment: .leading, spacing: 4) {
                    Group {
                        Text(address.firstLine + "\n") +
                        Text(address.secondLine)
                    }.textSelection(.enabled)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text(address.firstLine)
                    Text(address.secondLine)
                }
            }
            
        }
        
    }
    
}

struct AddressContainer_Previews: PreviewProvider {
    static var previews: some View {
        AddressContainer(address: AddressUiState(
            street: "Musterstraße",
            houseNumber: "42",
            place: "Musterstadt",
            postcode: "12345"
        ))
        .padding()
        .preferredColorScheme(.dark)
        .previewLayout(.sizeThatFits)
    }
}
