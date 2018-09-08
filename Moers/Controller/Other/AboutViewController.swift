//
//  AboutViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt

class AboutViewController: UIViewController {

    lazy var cfnImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "cfn")
        
        return imageView
        
    }()
    
    lazy var cfnLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.text = "CodeForNiederrhein"
        
        return label
        
    }()
    
    lazy var cfnTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.text = "Twitter: twitter.com/codefornrn\nWebsite: codeforniederrhein.de"
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        
        return textView
        
    }()
    
    lazy var meAvatarImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "avatar")
        
        return imageView
        
    }()
    
    lazy var nameLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.text = "Lennart Fischer"
        
        return label
        
    }()
    
    lazy var meTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.text = "Twitter: twitter.com/lambdadigamma\nWebsite: lambdadigamma.com"
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        
        return textView
        
    }()
    
    lazy var infoTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.text = "Diese App ist ein Projekt der Gruppe CodeForNiederrhein und wurde von Lennart Fischer entwickelt. Die Daten stammen aus dem OpenData-Portal der Stadt Moers (offenesdatenportal.de) und die 360° Panoramen werden von der Moerser Firma Telepano (telepano.de) zur Verfügung gestellt.\n\nSie vermissen Ihr Geschäft in dieser App, Daten sind nicht aktuell oder wollen Feedback geben?\n Kein Problem: Schreiben Sie einfach eine Email an moersapp@lambdadigamma.com!\n\nAlle Angaben zu Daten sind ohne Gewähr."
        textView.isEditable = false
        
        return textView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    private func setupUI() {
        
        self.title = String.localized("AboutTitle")
        
        self.view.addSubview(cfnImageView)
        self.view.addSubview(cfnLabel)
        self.view.addSubview(cfnTextView)
        self.view.addSubview(meAvatarImageView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(meTextView)
        self.view.addSubview(infoTextView)
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.fastForward, target: self, action: #selector(showDebug))
        
        navigationItem.rightBarButtonItem = barButtonItem
        
    }
    
    private func setupConstraints() {
        
        let constraints = [cfnImageView.widthAnchor.constraint(equalToConstant: 70),
                           cfnImageView.heightAnchor.constraint(equalTo: cfnImageView.widthAnchor),
                           cfnImageView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           cfnImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           cfnLabel.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
                           cfnLabel.leftAnchor.constraint(equalTo: cfnImageView.rightAnchor, constant: 8),
                           cfnLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           cfnTextView.topAnchor.constraint(equalTo: cfnLabel.bottomAnchor),
                           cfnTextView.leftAnchor.constraint(equalTo: cfnImageView.rightAnchor, constant: 4),
                           cfnTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           cfnTextView.heightAnchor.constraint(equalToConstant: 50),
                           meAvatarImageView.widthAnchor.constraint(equalTo: cfnImageView.widthAnchor),
                           meAvatarImageView.heightAnchor.constraint(equalTo: meAvatarImageView.widthAnchor),
                           meAvatarImageView.topAnchor.constraint(equalTo: cfnImageView.bottomAnchor, constant: 16),
                           meAvatarImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           nameLabel.topAnchor.constraint(equalTo: meAvatarImageView.topAnchor, constant: 0),
                           nameLabel.leftAnchor.constraint(equalTo: meAvatarImageView.rightAnchor, constant: 8),
                           nameLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           meTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
                           meTextView.leftAnchor.constraint(equalTo: meAvatarImageView.rightAnchor, constant: 4),
                           meTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           meTextView.heightAnchor.constraint(equalToConstant: 50),
                           infoTextView.topAnchor.constraint(equalTo: meTextView.bottomAnchor, constant: 16),
                           infoTextView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           infoTextView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           infoTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.cfnLabel.textColor = theme.color
            themeable.cfnTextView.textColor = theme.color
            themeable.cfnTextView.backgroundColor = theme.backgroundColor
            themeable.nameLabel.textColor = theme.color
            themeable.meTextView.textColor = theme.color
            themeable.meTextView.backgroundColor = theme.backgroundColor
            themeable.infoTextView.textColor = theme.color
            themeable.infoTextView.backgroundColor = theme.backgroundColor
        }
        
    }
    
    @objc private func showDebug() {
        
        let debugViewController = DebugViewController()
        
        self.navigationController?.pushViewController(debugViewController, animated: true)

        
    }

}
