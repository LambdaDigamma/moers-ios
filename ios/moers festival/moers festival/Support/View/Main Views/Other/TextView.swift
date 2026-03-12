//
//  TextView.swift
//  moers festival
//
//  Created by Lennart Fischer on 17.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class TextView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: TextViewModel
    
    init(viewModel: TextViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupBinding()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    private lazy var scrollView = { ViewFactory.scrollView() }()
    private lazy var contentView = { ViewFactory.blankView() }()
    private lazy var detailsTextView = { ViewFactory.textView() }()
    
    private func setupUI() {
        
        self.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(detailsTextView)
        
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.detailsTextView.font = UIFont.systemFont(ofSize: 14)
        self.detailsTextView.isEditable = false
        self.detailsTextView.isSelectable = false
        self.detailsTextView.isScrollEnabled = false
        self.detailsTextView.dataDetectorTypes = UIDataDetectorTypes.all
        self.detailsTextView.textContainerInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        self.detailsTextView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
    }
    
    private func setupBinding() {
        
        detailsTextView.text = viewModel.paragraph
        
    }
    
    private func setupConstraints() {
        
        let margins = self.readableContentGuide
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: margins.widthAnchor),
            detailsTextView.topAnchor.constraint(equalTo: contentView.topAnchor),
            detailsTextView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            detailsTextView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            detailsTextView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.detailsTextView.sizeToFit()
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.systemBackground
        self.detailsTextView.textColor = UIColor.label
        self.detailsTextView.backgroundColor = UIColor.systemBackground
        
    }
    
}
