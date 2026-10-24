//
//  FunctionParameterSyntax+ArgumentLabel.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension FunctionParameterSyntax {
    var argumentLabel: String? {
        return firstName.text == "_" ? nil : firstName.text
    }
}
#endif
