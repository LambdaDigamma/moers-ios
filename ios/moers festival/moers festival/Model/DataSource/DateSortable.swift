//
//  DateSortable.swift
//  moers festival
//
//  Created by Lennart Fischer on 16.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

//import TwitterKit
import Foundation

protocol DateSortable {
    var date: Date { get }
}

extension InstagramPost: DateSortable {
    
    var date: Date {
        return self.publishDate
    }
    
}


//extension TWTRTweet: DateSortable {
//    
//    var date: Date {
//        return self.createdAt
//    }
//    
//}
