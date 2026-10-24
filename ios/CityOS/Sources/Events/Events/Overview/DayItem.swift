//
//  DayItem.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

struct DayItem: View {

    let date: Date
    var isActive = false
    var onSelect: () -> Void = {}

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        styledButton
            .buttonBorderShape(.capsule)
            .controlSize(.large)
            .tint(.primary)
            .frame(minWidth: 44, minHeight: 44)
            .accessibilityIdentifier("DayItem-\(date.formatted(.dateTime.year().month().day()))")
            .accessibilityLabel(Text(date, format: .dateTime.weekday(.wide).day().month()))
            .accessibilityAddTraits(isActive ? .isSelected : [])
    }

    @ViewBuilder
    private var styledButton: some View {
        if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            if isActive {
                button
                    .buttonStyle(.glassProminent)
                    .foregroundStyle(selectedForeground)
            } else {
                button
                    .buttonStyle(.glass)
                    .foregroundStyle(.primary)
            }
        } else if isActive {
            button
                .buttonStyle(.borderedProminent)
                .foregroundStyle(selectedForeground)
        } else {
            button
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
        }
    }

    private var button: some View {
        Button(action: onSelect) {
            Text(date, format: .dateTime.weekday(.abbreviated).day())
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .lineLimit(1)
                .fixedSize()
                .frame(minHeight: 28)
        }
    }

    private var selectedForeground: Color {
        colorScheme == .dark ? .black : .white
    }

}

struct DayItem_Previews: PreviewProvider {
    static var previews: some View {
        DayItem(date: Date())
            .padding()
            .previewLayout(.sizeThatFits)
        
        DayItem(date: Date(), isActive: true)
            .padding()
            .previewLayout(.sizeThatFits)
            .previewDisplayName("Active")
    }
}
