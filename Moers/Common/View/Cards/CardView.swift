//
//  CardView.swift
//  Moers
//
//  Created by Lennart Fischer on 10.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import QuartzCore
import Gestalt
import MMUI

class CardView: UIView {

    public var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
        }
    }
    
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    private lazy var blurView: UIVisualEffectView = {
        
        let effect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurView = UIVisualEffectView(effect: effect)
        
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = self.cornerRadius
        blurView.clipsToBounds = true
        
        return blurView
        
    }()
    
    private lazy var titleLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
        
    }()
    
    private lazy var messageLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        return label
        
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
        
    }()
    
    private lazy var errorContainer: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.spacing = 8
        
        return stackView
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.applyTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyTheming() {
        
        applyBaseStyling(theme: .dark)
        
    }
    
    public func showError(withTitle title: String, message: String) {
        
        self.addSubview(blurView)
        self.addSubview(errorContainer)
        
        self.errorContainer.addArrangedSubview(titleLabel)
        self.errorContainer.addArrangedSubview(messageLabel)
        
        self.titleLabel.text = title
        self.messageLabel.text = message
        
        let constraints = [blurView.topAnchor.constraint(equalTo: self.topAnchor),
                           blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                           blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                           blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           errorContainer.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                           errorContainer.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                           errorContainer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
                           errorContainer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    public func dismissError() {
        
        self.blurView.removeFromSuperview()
        self.titleLabel.removeFromSuperview()
        self.messageLabel.removeFromSuperview()
        
    }
    
    public func startLoading() {
        
        self.addSubview(blurView)
        self.addSubview(activityIndicator)
        
        let constraints = [
            blurView.topAnchor.constraint(equalTo: self.topAnchor),
            blurView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        activityIndicator.startAnimating()
        
    }
    
    public func stopLoading() {
        
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()
        
        self.activityIndicator.removeFromSuperview()
        self.blurView.removeFromSuperview()
        
    }
    
    public func applyBaseStyling(theme: ApplicationTheme) {
        
        self.cornerRadius = 12.0
        self.backgroundColor = theme.cardBackgroundColor
        self.blurView.effect = theme.statusBarStyle == .default ? UIBlurEffect(style: .light) : UIBlurEffect(style: .dark)
        self.activityIndicator.style = theme.statusBarStyle == .default ? .gray : .white
        self.messageLabel.textColor = theme.color
        self.titleLabel.textColor = theme.color
        
        if theme.cardShadow {
            
            self.clipsToBounds = false
            self.shadowColor = UIColor.lightGray
            self.shadowOpacity = 0.6
            self.shadowRadius = 10.0
            self.shadowOffset = CGSize(width: 0, height: 0)
            
        } else {
            
            self.clipsToBounds = false
            self.shadowColor = UIColor.lightGray
            self.shadowOpacity = 0.0
            self.shadowRadius = 0.0
            self.shadowOffset = CGSize(width: 0, height: 0)
            
        }
        
    }
    
}
