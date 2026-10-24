//
//  FunctionDeclSyntax+IsClassMethod.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension FunctionDeclSyntax {
    var isClassMethod: Bool {
        return modifiers.contains { modifier in
            return modifier.name.text == "class" || modifier.name.text == "static"
        }
    }
}
#endif
