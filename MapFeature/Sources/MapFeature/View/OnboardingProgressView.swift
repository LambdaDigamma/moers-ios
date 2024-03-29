//
//  OnboardingProgressView.swift
//  Moers
//
//  Created by Lennart Fischer on 14.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Core

public class OnboardingProgressView: UIView {

    private lazy var currentStepLabel: UILabel = { return CoreViewFactory.label() }()
    private lazy var progressView: UIProgressView = { return CoreViewFactory.progressView() }()
    private lazy var separatorView: UIView = { return CoreViewFactory.blankView() }()
    
    public var accentColor: UIColor! {
        didSet {
            progressView.progressTintColor = accentColor
        }
    }
    
    public var decentColor: UIColor! {
        didSet {
            progressView.trackTintColor = decentColor
            separatorView.backgroundColor = decentColor
        }
    }
    
    public var textColor: UIColor! {
        didSet {
            currentStepLabel.textColor = textColor
        }
    }
    
    public var progress: Float = 0 {
        didSet {
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    public var currentStep: String = "" {
        didSet {
            self.currentStepLabel.text = currentStep
        }
    }
    
    public init() {
        super.init(frame: CGRect.zero)
        
        self.addSubview(currentStepLabel)
        self.addSubview(progressView)
        self.addSubview(separatorView)
        
        self.currentStepLabel.textAlignment = .center
        self.currentStepLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.separatorView.alpha = 0.75
        
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            currentStepLabel.topAnchor.constraint(equalTo: self.topAnchor),
            currentStepLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            currentStepLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: self.currentStepLabel.bottomAnchor, constant: 16),
            progressView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
            separatorView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            separatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.widthAnchor.constraint(equalToConstant: 48),
            separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
