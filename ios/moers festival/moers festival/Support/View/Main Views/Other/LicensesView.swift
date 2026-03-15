//
//  LicensesView.swift
//  moers festival
//
//  Created by Lennart Fischer on 18.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class LicensesView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: LicensesViewModel
    
    init(viewModel: LicensesViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupData()
        self.setupConstraints()
        self.setupTheming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    lazy var textView = { ViewFactory.textView() }()
    
    private func setupUI() {
        
        self.addSubview(textView)
        
        self.textView.isSelectable = false
        self.textView.isEditable = false
        
    }
    
    private func setupData() {
        
        self.textView.text = viewModel.text
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            textView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
            textView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.systemBackground
        self.textView.backgroundColor = UIColor.systemBackground
        self.textView.textColor = UIColor.label
        
    }
    
}
