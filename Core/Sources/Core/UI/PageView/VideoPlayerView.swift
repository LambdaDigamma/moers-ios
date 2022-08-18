//
//  VideoPlayerView.swift
//  MMUI
//
//  Created by Lennart Fischer on 14.05.20.
//

import UIKit
import AVFoundation

open class VideoPlayerView: UIView {
    
    public private(set) lazy var fullscreenButton: UIButton = { CoreViewFactory.button() }()
    
    public override init(frame: CGRect) {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setupConstraints()
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(fullscreenButton)
        
        let fullscreenImage = UIImage(named: "fullscreen")?.withRenderingMode(.alwaysTemplate)
        
        self.fullscreenButton.setImage(fullscreenImage, for: .normal)
        self.fullscreenButton.tintColor = UIColor.white
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            fullscreenButton.widthAnchor.constraint(equalToConstant: 40),
            fullscreenButton.heightAnchor.constraint(equalToConstant: 40),
            fullscreenButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            fullscreenButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Video Handling
    
    public var player: AVPlayer? {
        get {
            return playerLayer.player
        }

        set {
            playerLayer.player = newValue
        }
    }
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
}
