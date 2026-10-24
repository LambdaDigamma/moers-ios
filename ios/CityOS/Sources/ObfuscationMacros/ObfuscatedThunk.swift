//
//  ObfuscatedThunk.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax)
import SwiftSyntax

enum ObfuscatedThunk {
    static func name(for selector: String) -> String {
        return "__obfuscated_\(selector.identifierHash)"
    }

    static func selectorName(for function: FunctionDeclSyntax, thunkName: String) -> String {
        let parameters = function.parameters

        guard parameters.isEmpty == false else { return thunkName }

        return parameters.enumerated().map { index, _ in
            return index == 0 ? "\(thunkName):" : "a\(index):"
        }.joined()
    }
}
#endif
