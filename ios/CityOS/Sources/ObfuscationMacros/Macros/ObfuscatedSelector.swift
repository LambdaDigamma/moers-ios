//
//  ObfuscatedSelector.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

struct ObfuscatedMethodMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let function = declaration.as(FunctionDeclSyntax.self) else { throw ObfuscateError.notAMethod }

        guard let selector = node.firstStringArgument else { throw ObfuscateError.nonLiteralSelector }

        if function.hasEffectSpecifiers {
            throw ObfuscateError.unsupportedEffects
        }

        return [thunk(for: function, selector: selector)]
    }
}

private extension ObfuscatedMethodMacro {
    static func thunk(for function: FunctionDeclSyntax, selector: String) -> DeclSyntax {
        let thunkName = ObfuscatedThunk.name(for: selector)
        let thunkSelector = ObfuscatedThunk.selectorName(for: function, thunkName: thunkName)
        let keyword = function.isClassMethod ? "class func" : "func"
        let target = function.isClassMethod ? "Self" : "self"

        let returnSuffix = function.returnClauseText.map { text in
            return " \(text)"
        } ?? ""

        let parameterList = function.parameters.enumerated().map { index, parameter in
            return "_ p\(index): \(parameter.typeDescription)"
        }.joined(separator: ", ")

        let argumentList = function.parameters.enumerated().map { index, parameter in
            let value = "p\(index)"

            let argument = parameter.argumentLabel.map { label in
                return "\(label): \(value)"
            } ?? value

            return argument
        }.joined(separator: ", ")

        return """
        @objc(\(raw: thunkSelector))
        private \(raw: keyword) \(raw: thunkName)(\(raw: parameterList))\(raw: returnSuffix) {
            \(raw: target).\(raw: function.name.text)(\(raw: argumentList))
        }
        """
    }
}
#endif
