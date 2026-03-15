//
//  LoadingViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import Core

class LoadingViewController: UIViewController {
    
    private lazy var loadingContainer = { ViewFactory.stackView() }()
    private lazy var activityIndicator: UIActivityIndicatorView = { CoreViewFactory.spinner() }()
    private lazy var hintLabel: UILabel = { ViewFactory.label() }()
    
    private let hint: String
    
    init(loadingHint: String = "") {
        self.hint = loadingHint
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        activityIndicator.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        activityIndicator.stopAnimating()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        
        self.view.addSubview(loadingContainer)
        self.loadingContainer.axis = .vertical
        self.loadingContainer.alignment = .center
        self.loadingContainer.addArrangedSubview(activityIndicator)
        self.loadingContainer.addArrangedSubview(hintLabel)
        self.loadingContainer.spacing = 12
        
        self.hintLabel.text = hint
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            loadingContainer.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            loadingContainer.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
        ]

        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.activityIndicator.color = UIColor.secondaryLabel
        self.hintLabel.textColor = UIColor.secondaryLabel
        
    }
    
}

//extension LoadingViewController: StateViewControllerTransitioning {
//
//    func stateTransitionDuration(isAppearing: Bool) -> TimeInterval {
//        return 0.5
//    }
//
//    func stateTransitionWillBegin(isAppearing: Bool) {
//        if isAppearing {
//            view.alpha = 0
//            activityIndicator.transform = CGAffineTransform.identity.scaledBy(x: 3, y: 3)
//        }
//    }
//
//    func stateTransitionDidEnd(isAppearing: Bool) {
//        view.alpha = 1
//        activityIndicator.transform = .identity
//    }
//
//    func animateAlongsideStateTransition(isAppearing: Bool) {
//        if isAppearing {
//            view.alpha = 1
//            activityIndicator.transform = .identity
//        } else {
//            view.alpha = 0
//            activityIndicator.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
//        }
//    }
//
//    func stateTransitionDelay(isAppearing: Bool) -> TimeInterval {
//        return isAppearing ? 0 : 0.5
//    }
//
//}
