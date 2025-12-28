//
//  TextViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 25.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class TextViewController: UIViewController {
    
    // MARK: - Properties
    
    public var coordinator: OtherCoordinator?
    
    private let viewModel: TextViewModel
    private let textView: TextView
    
    init(viewModel: TextViewModel) {
        self.viewModel = viewModel
        self.textView = TextView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func loadView() {
        view = textView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    private func setupUI() {
        
    }
    
}
