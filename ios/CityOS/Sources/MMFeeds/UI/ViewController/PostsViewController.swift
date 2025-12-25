//
//  PostsViewController.swift
//  
//
//  Created by Lennart Fischer on 10.04.23.
//

import Core
import UIKit
import MMPages
import SwiftUI

public class PostsViewController: UIViewController {
    
    private let viewModel: FeedPostListViewModel
    private let onShowPost: ((Post.ID) -> Void)
    
    public init(feedID: Feed.ID, onShowPost: @escaping ((Post.ID) -> Void)) {
        
        self.viewModel = FeedPostListViewModel(
            feedID: 3,
            postsPerLoad: 10,
            automaticallyLoadFirstPage: false
        )
        self.onShowPost = onShowPost
        
        super.init(nibName: nil, bundle: nil)
        
        self.setupUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func setupUI() {
        
        let screen = FeedViewScreen(viewModel: viewModel, showPost: onShowPost)
        
        self.addSubSwiftUIView(screen, to: view)
        
    }
    
}
