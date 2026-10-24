//
//  String+XORKey.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

extension String {
    var xorKey: UInt8 {
        let seed: UInt32 = 0x9e37_79b9
        let multiplier: UInt32 = 31
        let fallbackKey: UInt8 = 0x5a

        var hash = seed

        for byte in utf8 {
            hash = (hash &* multiplier) &+ UInt32(byte)
        }

        let key = UInt8(truncatingIfNeeded: hash)

        return key == 0 ? fallbackKey : key
    }
}
