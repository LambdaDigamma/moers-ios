//
//  TripStyle.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI

private struct AccentKey: EnvironmentKey {
    static let defaultValue = Color.accentColor
}

extension EnvironmentValues {
    var accent: Color {
        get { self[AccentKey.self] }
        set { self[AccentKey.self] = newValue }
    }
}

private struct OnAccentKey: EnvironmentKey {
    static let defaultValue = Color.black
}

extension EnvironmentValues {
    var onAccent: Color {
        get { self[OnAccentKey.self] }
        set { self[OnAccentKey.self] = newValue }
    }
}

extension View {
    func efaAccentColor(_ color: Color) -> some View {
        environment(\.accent, color)
    }
    func efaOnAccentColor(_ color: Color) -> some View {
        environment(\.onAccent, color)
    }
}
