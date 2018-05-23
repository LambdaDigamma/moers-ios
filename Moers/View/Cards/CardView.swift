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
        
        let effect = UIBlurEffect(style: UIBlurEffectStyle.light)
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
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
        
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        return activityIndicator
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.applyTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func applyTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.cornerRadius = 12.0
            themeable.backgroundColor = theme.cardBackgroundColor
            themeable.blurView.effect = theme.statusBarStyle == .default ? UIBlurEffect(style: .light) : UIBlurEffect(style: .dark)
            themeable.activityIndicator.activityIndicatorViewStyle = theme.statusBarStyle == .default ? .gray : .white
            themeable.messageLabel.textColor = theme.color
            themeable.titleLabel.textColor = theme.color
            
            if theme.cardShadow {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.6
                themeable.shadowRadius = 10.0
                themeable.shadowOffset = CGSize(width: 0, height: 0)
                
            } else {
                
                themeable.clipsToBounds = false
                themeable.shadowColor = UIColor.lightGray
                themeable.shadowOpacity = 0.0
                themeable.shadowRadius = 0.0
                themeable.shadowOffset = CGSize(width: 0, height: 0)
                
            }
            
        }
        
    }
    
    public func showError(withTitle title: String, message: String) {
        
        self.addSubview(blurView)
        self.addSubview(messageLabel)
        self.addSubview(titleLabel)
        
        self.titleLabel.text = title
        self.messageLabel.text = message
        
        let constraints = [blurView.topAnchor.constraint(equalTo: self.topAnchor),
                           blurView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           blurView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           messageLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                           messageLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                           messageLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           messageLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
                           titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -16),
                           titleLabel.bottomAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8)]
        
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
        
        let constraints = [blurView.topAnchor.constraint(equalTo: self.topAnchor),
                           blurView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           blurView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           blurView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                           activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                           activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
        activityIndicator.startAnimating()
        
    }
    
    public func stopLoading() {
        
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.stopAnimating()
        
        self.activityIndicator.removeFromSuperview()
        self.blurView.removeFromSuperview()
        
    }
    
}
