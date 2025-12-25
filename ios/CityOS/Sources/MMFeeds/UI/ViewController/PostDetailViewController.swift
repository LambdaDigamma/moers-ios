//
//  PostDetailViewController.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import UIKit
import MMPages

public class PostDetailViewController: UIViewController {

    private let postID: Post.ID
    
    private let viewModel: PostViewModel
    private let actionTransmitter: ActionTransmitter
    
    public init(postID: Post.ID) {
        self.postID = postID
        self.viewModel = .init(postID: postID)
        self.actionTransmitter = ActionTransmitter()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
    }
    
    private func setupUI() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        
        let screen = PostDetailScreen(viewModel: viewModel)
            .environmentObject(actionTransmitter)
        
        self.addSubSwiftUIView(screen, to: view)
        
    }
    
}
