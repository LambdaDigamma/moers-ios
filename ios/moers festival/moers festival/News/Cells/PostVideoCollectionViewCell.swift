//
//  PostVideoCollectionViewCell.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import Foundation
import MMFeeds

class PostVideoCollectionViewCell: BaseRoundedCardCell {
    
    var post: Post?

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
