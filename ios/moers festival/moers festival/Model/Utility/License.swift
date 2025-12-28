//
//  License.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import Foundation

struct License {
    
    let framework: String
    let name: String
    let text: String
    
    static func loadFromPlist() -> [License] {
        
        guard let url = Bundle.main.url(forResource: "Licenses", withExtension: "plist") else { return [] }
        
        var licenses: [License] = []
        
        do {
            
            if let data = try? Data(contentsOf: url) {
                
                let decoder = PropertyListDecoder()
                licenses = try decoder.decode([License].self, from: data)
                
            }
            
        } catch let err {
            print(err.localizedDescription)
        }
        
        return licenses
        
    }
    
}

extension License: Decodable {
    
    enum MyStructKeys: String, CodingKey {
        case framework = "title"
        case name = "license"
        case text = "text"
    }
    
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: MyStructKeys.self)
        let framework = try container.decode(String.self, forKey: .framework)
        let name = try container.decode(String.self, forKey: .name)
        let text = try container.decode(String.self, forKey: .text)
       
        self.init(framework: framework, name: name, text: text)
    }
    
}
