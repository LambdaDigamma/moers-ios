//
//  DetailDisclosureView.swift
//  MMUI
//
//  Created by Lennart Fischer on 25.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit

public class DetailDisclosureView: UIView {
    
    @IBInspectable
    public var color: UIColor = UIColor.darkGray {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        
        let context = UIGraphicsGetCurrentContext()
        let x = self.bounds.maxX - 3
        let y = self.bounds.midY
        let R = CGFloat(4.5)
        context?.move(to: CGPoint(x: x-R, y: y-R))
        context?.addLine(to: CGPoint(x: x, y: y))
        context?.addLine(to: CGPoint(x: x-R, y: y+R))
        context?.setLineCap(.square)
        context?.setLineJoin(.miter)
        context?.setLineWidth(2)
        color.setStroke()
        context?.strokePath()
        
    }
}
