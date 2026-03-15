//
//  SponsorViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 04.05.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import SafariServices

class SponsorViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    
    public var coordinator: OtherCoordinator?
    
    private let viewModel: SponsorViewModel
    private let sponsorView: SponsorView
    
    init(viewModel: SponsorViewModel) {
        self.viewModel = viewModel
        self.sponsorView = SponsorView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func loadView() {
        view = sponsorView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        AnalyticsManager.shared.logOpenPartner()
        
    }
    
    private func setupUI() {
        
        self.title = String.localized("SponsorTitle")
        
        self.sponsorView.setCollectionViewDelegate(self)
        
    }
    
    // MARK: - UICollectionViewDataSource & UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width / 2 - 8, height: 100.0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
        // ToDo: Fix selection
        
//        let sponsor = viewModel.sponsors.collection.item(at: indexPath)
//
//        guard let url = sponsor.url else { return }
//
//        let config = SFSafariViewController.Configuration()
//
//        config.barCollapsingEnabled = true
//
//        let vc = SFSafariViewController(url: url, configuration: config)
//        vc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
//        vc.preferredControlTintColor = navigationController?.navigationBar.tintColor
//
//        self.present(vc, animated: true)
        
    }
    
}
