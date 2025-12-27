//
//  LocationTypeIcon.swift
//  CityOS
//
//  Created by Lennart Fischer on 27.12.25.
//

import SwiftUI

struct LocationTypeIcon: View {
    
    let gradient: LinearGradient
    let foregroundColor: Color
    
    init(
        gradient: LinearGradient,
        foregroundColor: Color
    ) {
        self.gradient = gradient
        self.foregroundColor = foregroundColor
    }
    
    init(
        backgroundColor: Color,
        foregroundColor: Color
    ) {
        self.gradient = LinearGradient(
            colors: [
                backgroundColor.adjustBrightness(0.15),
                backgroundColor,
                backgroundColor.adjustBrightness(-0.2)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        
        Circle()
            .fill(gradient)
            .overlay(alignment: .center) {
                Image(systemName: "fuelpump.fill")
                    .resizable()
                    .foregroundStyle(foregroundColor)
                    .imageScale(.medium)
                    .padding(16)
            }
            .shadowMD()
        
    }
    
}

extension Color {
    
    func adjustBrightness(_ amount: Double) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self
        }
        
        return Color(
            hue: Double(h),
            saturation: Double(s),
            brightness: min(max(Double(b) + amount, 0), 1),
            opacity: Double(a)
        )
    }
    
}

#Preview {
    LocationTypeIcon(
        backgroundColor: Color.blue,
        foregroundColor: Color.white
    )
        .frame(maxWidth: 50)
}
