//
//  UIImage+Extensions.swift
//  Moers
//
//  Created by Lennart Fischer on 23.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

extension UIImage {
    
    func tinted(color: UIColor) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()
        
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)
        
        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // TODO: Check whether this works
    func newTinted(color: UIColor) -> UIImage {
        
        let renderer = UIGraphicsImageRenderer(size: self.size)
        
        let image = renderer.image { ctx in
            
            color.setFill()
            
            ctx.cgContext.translateBy(x: 0, y: self.size.height)
            ctx.cgContext.scaleBy(x: 1.0, y: -1.0)
            ctx.cgContext.setBlendMode(.normal)
            
            let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
            ctx.cgContext.clip(to: rect, mask: self.cgImage!)
            ctx.cgContext.fill(rect)
            
        }
        
        return image
        
    }
    
}
