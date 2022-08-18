//
//  Extensions.swift
//  
//
//  Created by Lennart Fischer on 10.06.21.
//

import Foundation

public extension Collection {
    
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
}

internal extension String {
    
    static func localized(_ key: String) -> String {
        return NSLocalizedString(key, bundle: Bundle.main, value: "", comment: "")
    }
    
}

extension NewsViewModel {
    
    public static let mocked: [NewsViewModel] = [
        .init(headline: "Camping mit dem Hund: Rheurdter baut Wohnmobile tiergerecht um", link: URL(string: "https://example.org")!),
        .init(headline: "Sinkende Inzidenz, weniger Intensivpatienten", link: URL(string: "https://example.org")!),
        .init(headline: "Kulturprojekt am Niederrhein: Die Provinz in allen Facetten beleuchtet", link: URL(string: "https://example.org")!),
        .init(headline: "Neun Stationen in und rund um Moers: Eine Rallye übers Land", link: URL(string: "https://example.org")!)
    ]
    
}
