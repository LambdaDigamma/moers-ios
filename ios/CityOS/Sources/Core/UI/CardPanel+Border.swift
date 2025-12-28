//
//  CardPanel+Border.swift
//  CityOS
//
//  Created by Lennart Fischer on 28.12.25.
//

import SwiftUI

public struct CardPanelBorder {
    public let color: Color
    public let lineWidth: CGFloat
    
    public init(color: Color, lineWidth: CGFloat = 1) {
        self.color = color
        self.lineWidth = lineWidth
    }
}

private struct CardPanelBorderKey: EnvironmentKey {
    static let defaultValue: CardPanelBorder? = nil
}

public extension EnvironmentValues {
    var cardPanelBorder: CardPanelBorder? {
        get { self[CardPanelBorderKey.self] }
        set { self[CardPanelBorderKey.self] = newValue }
    }
}

public extension View {
    func cardPanelBorder(_ border: CardPanelBorder?) -> some View {
        environment(\.cardPanelBorder, border)
    }
}
