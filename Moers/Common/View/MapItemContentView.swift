//
//  MapItemContentView.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import ESTabBarController
import Gestalt
import MMUI

class BasicItemContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension BasicItemContentView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.backdropColor = UIColor.clear
        self.highlightBackdropColor = UIColor.clear
        self.iconColor = UIColor.secondaryLabel // theme.decentColor
        self.textColor = UIColor.secondaryLabel // theme.decentColor
        self.highlightIconColor = UIColor.label // theme.accentColor
        self.highlightTextColor = UIColor.label // theme.accentColor
    }
    
}

class ItemBounceContentView: BasicItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
}

class MapItemContentView: ESTabBarItemContentView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.imageView.layer.borderWidth = 3.0
        self.imageView.layer.cornerRadius = 35
        self.imageView.clipsToBounds = true
        self.insets = UIEdgeInsets(top: -32, left: 0, bottom: 0, right: 0)
        self.imageView.transform = CGAffineTransform.identity
        self.superview?.bringSubviewToFront(self)
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let p = CGPoint.init(x: point.x - imageView.frame.origin.x, y: point.y - imageView.frame.origin.y)
        return sqrt(pow(imageView.bounds.size.width / 2.0 - p.x, 2) + pow(imageView.bounds.size.height / 2.0 - p.y, 2)) < imageView.bounds.size.width / 2.0
    }
    
    override func updateLayout() {
        super.updateLayout()
        self.imageView.sizeToFit()
        self.imageView.center = CGPoint.init(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
    }
    
    public override func selectAnimation(animated: Bool, completion: (() -> ())?) {
        let view = UIView.init(frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: 2.0, height: 2.0)))
        view.layer.cornerRadius = 1.0
        view.layer.opacity = 0.5
        view.backgroundColor = UIColor.init(red: 10 / 255.0, green: 66 / 255.0, blue: 91 / 255.0, alpha: 1.0)
        self.addSubview(view)
        playMaskAnimation(animateView: view, target: self.imageView, completion: {
            [weak view] in
            view?.removeFromSuperview()
            completion?()
        })
    }
    
    public override func reselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func deselectAnimation(animated: Bool, completion: (() -> ())?) {
        completion?()
    }
    
    public override func highlightAnimation(animated: Bool, completion: (() -> ())?) {
        
        UIView.animate(withDuration: 0.2) {
            let transform = self.imageView.transform.scaledBy(x: 0.8, y: 0.8)
            self.imageView.transform = transform
        } completion: { (finished) in
            if finished {
                completion?()
            }
        }

    }
    
    public override func dehighlightAnimation(animated: Bool, completion: (() -> ())?) {
        
        UIView.animate(withDuration: 0.2) {
            let transform = CGAffineTransform.identity
            self.imageView.transform = transform
        } completion: { (finished) in
            if finished {
                completion?()
            }
        }
        
    }
    
    private func playMaskAnimation(animateView view: UIView, target: UIView, completion: (() -> ())?) {
//        view.center = CGPoint.init(x: target.frame.origin.x + target.frame.size.width / 2.0, y: target.frame.origin.y + target.frame.size.height / 2.0)
//
//        let scale = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
//        scale?.fromValue = NSValue(cgSize: CGSize.init(width: 1.0, height: 1.0))
//        scale?.toValue = NSValue(cgSize: CGSize.init(width: 36.0, height: 36.0))
//        scale?.beginTime = CACurrentMediaTime()
//        scale?.duration = 0.3
//        scale?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        scale?.removedOnCompletion = true
//
//        let alpha = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
//        alpha?.fromValue = 0.6
//        alpha?.toValue = 0.6
//        alpha?.beginTime = CACurrentMediaTime()
//        alpha?.duration = 0.25
//        alpha?.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
//        alpha?.removedOnCompletion = true
//
//        view.layer.pop_add(scale, forKey: "scale")
//        view.layer.pop_add(alpha, forKey: "alpha")
//
//        scale?.completionBlock = ({ animation, finished in
//            completion?()
//        })
    }
    
}

extension MapItemContentView: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        self.imageView.backgroundColor = theme.accentColor
        self.imageView.layer.borderColor = theme.navigationBarColor.cgColor
        self.textColor = theme.decentColor
        self.iconColor = theme.navigationBarColor
        self.highlightIconColor = theme.navigationBarColor
        self.highlightTextColor = theme.accentColor
        self.backdropColor = .clear
    }
    
}
