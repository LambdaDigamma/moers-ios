//
//  FunctionParameterSyntax+TypeDescription.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension FunctionParameterSyntax {
    var typeDescription: String {
        return type.trimmedDescription
    }
}
#endif
