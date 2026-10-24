//
//  FunctionDeclSyntax+ObfuscatedSelector.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension FunctionDeclSyntax {
    var obfuscatedSelector: String? {
        for attribute in attributes {
            guard let attributeSyntax = attribute.as(AttributeSyntax.self),
                  attributeSyntax.attributeName.trimmedDescription == "Obfuscate",
                  let selector = attributeSyntax.firstStringArgument
            else { continue }

            return selector
        }

        return nil
    }
}
#endif
