//
//  AttributeSyntax+FirstStringArgument.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension AttributeSyntax {
    var firstStringArgument: String? {
        return arguments?
            .as(LabeledExprListSyntax.self)?
            .first?
            .expression
            .as(StringLiteralExprSyntax.self)?
            .representedLiteralValue
    }
}
#endif
