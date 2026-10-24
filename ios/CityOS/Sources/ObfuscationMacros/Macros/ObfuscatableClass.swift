//
//  ObfuscatableClass.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

#if canImport(SwiftSyntax) && canImport(SwiftSyntaxMacros)
import SwiftSyntax
import SwiftSyntaxMacros

struct ObfuscatableMacro: MemberMacro {
    public static func expansion(of node: AttributeSyntax, providingMembersOf declaration: some DeclGroupSyntax, conformingTo protocols: [TypeSyntax], in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else { throw ObfuscateError.notAClass }

        let typeName = classDecl.name.text

        let installCalls = classDecl.memberBlock.members.compactMap { member in
            return installCall(for: member, in: typeName)
        }

        guard installCalls.isEmpty == false else { return [] }

        let bootstrap: DeclSyntax = """
        private static let __installObfuscatedMethods: Void = {
            \(raw: installCalls.joined(separator: "\n    "))
        }()
        """

        let resolveInstanceMethod: DeclSyntax = """
        override class func resolveInstanceMethod(_ selector: Selector!) -> Bool {
            _ = __installObfuscatedMethods

            return super.resolveInstanceMethod(selector)
        }
        """

        let resolveClassMethod: DeclSyntax = """
        override class func resolveClassMethod(_ selector: Selector!) -> Bool {
            _ = __installObfuscatedMethods

            return super.resolveClassMethod(selector)
        }
        """

        return [bootstrap, resolveInstanceMethod, resolveClassMethod]
    }
}

private extension ObfuscatableMacro {
    static func installCall(for member: MemberBlockItemSyntax, in typeName: String) -> String? {
        guard let function = member.decl.as(FunctionDeclSyntax.self) else { return nil }

        guard let selector = function.obfuscatedSelector else { return nil }

        let thunkName = ObfuscatedThunk.name(for: selector)
        let thunkSelector = ObfuscatedThunk.selectorName(for: function, thunkName: thunkName)
        let key = selector.xorKey
        let keyLiteral = "0x" + String(key, radix: 16)

        let encodedBytes = selector.utf8.map { byte in
            return "0x" + String(byte ^ key, radix: 16)
        }.joined(separator: ", ")

        return "_installObfuscatedOverride(encoded: [\(encodedBytes)], key: \(keyLiteral), thunk: \"\(thunkSelector)\", isClassMethod: \(function.isClassMethod), on: \(typeName).self)"
    }
}
#endif
