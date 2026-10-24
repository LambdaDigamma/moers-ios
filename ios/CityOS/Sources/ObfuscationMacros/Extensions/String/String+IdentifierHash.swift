//
//  String+IdentifierHash.swift
//  CityOS
//
//  Created by Seb Vidal on 04/09/2026.
//

extension String {
    /// A short, stable hex string derived from the receiver, used as a unique
    /// suffix for a generated identifier. Uses the FNV-1a hash — deterministic,
    /// so the same input yields the same identifier on every build.
    var identifierHash: String {
        let offsetBasis: UInt32 = 0x811c_9dc5
        let prime: UInt32 = 0x0100_0193

        var hash = offsetBasis

        for byte in utf8 {
            hash = (hash ^ UInt32(byte)) &* prime
        }

        return String(hash, radix: 16)
    }
}
