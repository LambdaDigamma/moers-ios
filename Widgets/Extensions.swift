//
//  Extension.swift
//  Watch Extension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import NewsWidgets

extension NewsViewModel {
    
    public static let mocked: [NewsViewModel] = [
        .init(headline: "Camping mit dem Hund: Rheurdter baut Wohnmobile tiergerecht um", link: URL(string: "https://example.org")!),
        .init(headline: "Sinkende Inzidenz, weniger Intensivpatienten", link: URL(string: "https://example.org")!),
        .init(headline: "Kulturprojekt am Niederrhein: Die Provinz in allen Facetten beleuchtet", link: URL(string: "https://example.org")!),
        .init(headline: "Neun Stationen in und rund um Moers: Eine Rallye übers Land", link: URL(string: "https://example.org")!)
    ]
    
}
