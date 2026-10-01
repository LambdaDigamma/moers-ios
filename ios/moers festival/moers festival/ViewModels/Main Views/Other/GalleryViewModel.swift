//
//  GalleryViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import INSPhotoGallery

class GalleryViewModel: ObservableObject {
    
    @Published public var title: String
    @Published public var images: [INSPhotoViewable]
    
    init(title: String, images: [INSPhotoViewable]) {
        self.title = title
        self.images = images
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
