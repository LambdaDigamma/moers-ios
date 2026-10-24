//
//  FunctionDeclSyntax+HasEffectSpecifiers.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

extension FunctionDeclSyntax {
    var hasEffectSpecifiers: Bool {
        return signature.effectSpecifiers != nil
    }
}
#endif
