//
//  GalleryViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.01.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import INSPhotoGallery

class GalleryViewController: UIViewController {

    // MARK: - Properties
    
    public var coordinator: OtherCoordinator?
    
    private let viewModel: GalleryViewModel
    private let galleryView: GalleryView
    
    private lazy var images: [INSPhotoViewable] = { return viewModel.images }()
    
    init(viewModel: GalleryViewModel) {
        self.viewModel = viewModel
        self.galleryView = GalleryView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func loadView() {
        view = galleryView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = viewModel.title
        
        self.galleryView.setCollectionViewDelegate(self)
        
    }
    
}

extension GalleryViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! GalleryCollectionViewCell
        
        let currentPhoto = images[indexPath.row]
        let galleryPreview = INSPhotosViewController(photos: images, initialPhoto: currentPhoto, referenceView: cell)
        
        galleryPreview.referenceViewForPhotoWhenDismissingHandler = { [weak self] photo in
            if let index = self?.images.firstIndex(where: {$0 === photo}) {
                let indexPath = IndexPath(item: index, section: 0)
                return collectionView.cellForItem(at: indexPath) as? GalleryCollectionViewCell
            }
            return nil
        }
        
        self.present(galleryPreview, animated: true, completion: nil)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let collectionViewWidth = collectionView.frame.width
        
        var ratio: CGFloat = 1.0
        
        if let size = images[indexPath.row].image?.size {
            ratio = size.height / size.width
        }
        
        let size = CGSize(width: collectionViewWidth, height: collectionViewWidth * ratio)
        
        return size
        
    }
    
}
