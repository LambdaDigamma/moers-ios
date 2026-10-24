//
//  ObfuscateError.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

enum ObfuscateError: Error, CustomStringConvertible {
    case notAMethod
    case notAClass
    case nonLiteralSelector
    case unsupportedEffects

    var description: String {
        switch self {
        case .notAMethod:
            return "@Obfuscate can only be applied to a method."
        case .notAClass:
            return "@Obfuscatable can only be applied to a class."
        case .nonLiteralSelector:
            return "@Obfuscate requires a string-literal selector."
        case .unsupportedEffects:
            return "@Obfuscate does not support async or throwing methods."
        }
    }
}
