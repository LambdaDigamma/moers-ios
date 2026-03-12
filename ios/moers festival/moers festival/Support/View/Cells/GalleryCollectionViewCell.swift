//
//  GalleryCollectionViewCell.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.01.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import INSPhotoGallery

class GalleryCollectionViewCell: UICollectionViewCell {
    
    private lazy var imageView = { ViewFactory.imageView() }()
    
    // MARK: - Inits
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView.image = nil
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.layoutMargins = .zero
        
        self.contentView.addSubview(imageView)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
                           imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                           imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                           imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Public Methods
    
    public func populateWithPhoto(_ photo: INSPhotoViewable) {
        photo.loadThumbnailImageWithCompletionHandler { [weak photo] (image, error) in
            if let image = image {
                if let photo = photo as? INSPhoto {
                    photo.thumbnailImage = image
                }
                self.imageView.image = image
            }
        }
    }
    
}
