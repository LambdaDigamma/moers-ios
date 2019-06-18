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
