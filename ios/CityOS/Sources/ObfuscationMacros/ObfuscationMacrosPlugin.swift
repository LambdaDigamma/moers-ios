//
//  ObfuscationMacrosPlugin.swift
//  CityOS
//
//  Created by Seb Vidal on 15/07/2025.
//

#if canImport(SwiftCompilerPlugin) && canImport(SwiftSyntaxMacros) && canImport(SwiftSyntax)
import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct ObfuscateMacro: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        Obfuscate.self,
        ObfuscatedMethodMacro.self,
        ObfuscatableMacro.self
    ]
}
#endif
