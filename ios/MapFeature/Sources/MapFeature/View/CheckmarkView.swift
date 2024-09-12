//
//  CheckmarkView.swift
//  
//
//  Created by Lennart Fischer on 23.04.22.
//

#if canImport(UIKit)

import UIKit

public class CheckmarkView: UIView {
    
    // MARK: - Enumerations
    
    public enum Style: Int {
        case nothing
        case gray
        case green
    }
    
    // MARK: - Public Properties
    
    public var style: Style = .nothing {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // MARK: - Drawing
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.backgroundColor = UIColor.clear
        
        if style == .gray {
            drawCheckmark(color: UIColor.gray)
        } else if style == .green {
            drawCheckmark(color: UIColor.green)
        }
        
    }
    
    func drawCheckmark(color: UIColor) {
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        let bounds = self.bounds
        
        let group = CGRect(x: bounds.minX,
                           y: bounds.minY,
                           width: bounds.width,
                           height: bounds.height)
        
        context.saveGState()
        context.restoreGState()
        
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: group.minX + 0.27083 * group.width,
                                    y: group.minY + 0.54167 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.41667 * group.width,
                                       y: group.minY + 0.68750 * group.height))
        bezierPath.addLine(to: CGPoint(x: group.minX + 0.75000 * group.width,
                                       y: group.minY + 0.35417 * group.height))
        bezierPath.lineCapStyle = CGLineCap.square
        
        color.setStroke()
        bezierPath.lineWidth = 1.3 * 2
        bezierPath.stroke()
        
    }
    
}

#endif
