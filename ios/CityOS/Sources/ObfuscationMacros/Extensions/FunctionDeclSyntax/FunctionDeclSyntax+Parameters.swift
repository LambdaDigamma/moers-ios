//
//  FunctionDeclSyntax+Parameters.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension FunctionDeclSyntax {
    var parameters: FunctionParameterListSyntax {
        return signature.parameterClause.parameters
    }
}
#endif
