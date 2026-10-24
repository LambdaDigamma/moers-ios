//
//  ObfuscatedMethodInstaller.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

import Foundation
import ObjectiveC

public func _installObfuscatedOverride(encoded: [UInt8], key: UInt8, thunk thunkName: String, isClassMethod: Bool, on target: AnyClass) {
    let selectorName = String(decoding: encoded.map { byte in return byte ^ key }, as: UTF8.self)
    let selector = NSSelectorFromString(selectorName)
    let scope: AnyClass = isClassMethod ? (object_getClass(target) ?? target) : target

    guard let method = _obfuscatedThunkMethod(named: thunkName, on: scope) else { return }

    _ = class_addMethod(scope, selector, method_getImplementation(method), method_getTypeEncoding(method))
}

// Finds the thunk by scanning the method list directly rather than via
// class_getInstanceMethod / class_getClassMethod, which would re-enter the
// runtime's method resolver.
private func _obfuscatedThunkMethod(named name: String, on scope: AnyClass) -> Method? {
    let selector = NSSelectorFromString(name)
    var current: AnyClass? = scope

    while let klass = current {
        var count: UInt32 = 0

        if let methods = class_copyMethodList(klass, &count) {
            defer { free(methods) }

            for index in 0..<Int(count) {
                let method = methods[index]

                if method_getName(method) == selector {
                    return method
                }
            }
        }

        current = class_getSuperclass(klass)
    }

    return nil
}
