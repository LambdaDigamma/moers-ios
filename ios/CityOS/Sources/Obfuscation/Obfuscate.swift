//
//  Obfuscate.swift
//  CityOS
//
//  Created by Seb Vidal on 15/07/2025.
//


import Foundation

@freestanding(expression)
public macro Obfuscate(_ string: StaticString) -> String = #externalMacro(module: "ObfuscationMacros", type: "Obfuscate")

@attached(peer, names: arbitrary)
public macro Obfuscate(_ selector: String) = #externalMacro(module: "ObfuscationMacros", type: "ObfuscatedMethodMacro")

@attached(member, names: named(resolveClassMethod), named(resolveInstanceMethod), arbitrary)
public macro Obfuscatable() = #externalMacro(module: "ObfuscationMacros", type: "ObfuscatableMacro")
