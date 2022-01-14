//
//  LinesVerticalGraph.swift
//  
//
//  Created by Lennart Fischer on 11.01.22.
//

import SwiftUI

struct LinesVerticalGraph: View {
    
    var dataPoints: [Double] = [
        0.8,
        0.9,
        1,
        0.8,
        0.7,
        0.7,
        0.5,
        0.6,
        0.9
    ]
    
    let space: CGFloat = 4
    
    var body: some View {
        
        GeometryReader { geo in
            Path { path in
                
                let numberOfSpacers: CGFloat = CGFloat(dataPoints.count - 1)
                let width = geo.size.width / Double(dataPoints.count) - numberOfSpacers * space
                
                let rects = dataPoints.enumerated().map { (index, dataPoint) in
                    
                    CGRect(
                        x: width * CGFloat(index) + CGFloat(index) * space,
                        y: 0,
                        width: width,
                        height: 100
                    )
                    
                }
                
                path.addRects(rects)
                
            }
            
        }
        
    }
    
}

struct LinesVerticalGraph_Previews: PreviewProvider {
    static var previews: some View {
        LinesVerticalGraph()
    }
}
