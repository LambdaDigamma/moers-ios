//
//  OtherViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation

nonisolated struct OtherHeroContent: Hashable, Sendable {
    let title: String
    let subtitle: String
    let symbolName: String
    let iconStyle: RowIconStyle
}

struct OtherViewModel {
    
    // MARK: - Properties
    
    public var updateHandler: () -> Void = {}

    let hero: OtherHeroContent
    
    var sections: [Section]
    
    public init(hero: OtherHeroContent, sections: [Section]) {
        self.hero = hero
        self.sections = sections
    }
    
    public var numberOfSections: Int {
        return sections.count
    }
    
    public func numberOfRows(in section: Int) -> Int {
        return sections[section].rows.count
    }
    
    public func title(for indexPath: IndexPath) -> String {
        return sections[indexPath.section].rows[indexPath.row].title
    }
    
    public func header(for section: Int) -> String {
        return sections[section].title
    }
    
    public func rowAction(for indexPath: IndexPath) -> (() -> Void)? {
        
        return sections[indexPath.section].rows[indexPath.row].action
        
    }
    
}
