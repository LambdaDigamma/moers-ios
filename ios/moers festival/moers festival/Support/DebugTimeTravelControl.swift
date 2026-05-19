//
//  DebugTimeTravelControl.swift
//  moers festival
//
//  Created by Codex on 16.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

#if DEBUG

import SwiftUI

struct DebugTimeTravelControl: View {

    @ObservedObject var controller: DebugTimeController
    @ObservedObject var overlayState: DebugTimeOverlayState

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if overlayState.isControlVisible {
                panel
                    .background(panelFrameReader)
                    .padding(.trailing, 14)
                    .padding(.bottom, 18)
                    .transition(.scale(scale: 0.9, anchor: .bottomTrailing).combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .coordinateSpace(name: DebugTimePanelFramePreferenceKey.coordinateSpaceName)
        .onPreferenceChange(DebugTimePanelFramePreferenceKey.self) { frame in
            overlayState.interactiveFrame = overlayState.isControlVisible ? frame : nil
        }
        .onChange(of: overlayState.isControlVisible) { isVisible in
            if !isVisible {
                overlayState.interactiveFrame = nil
            }
        }
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: overlayState.isControlVisible)
    }

    private var panelFrameReader: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: DebugTimePanelFramePreferenceKey.self,
                value: proxy.frame(
                    in: .named(DebugTimePanelFramePreferenceKey.coordinateSpaceName)
                )
            )
        }
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 12) {
            header

            DatePicker(
                "Simulated Time",
                selection: Binding(
                    get: { controller.now },
                    set: { controller.setDate($0) }
                ),
                displayedComponents: [.date, .hourAndMinute]
            )
            .labelsHidden()
            .datePickerStyle(.compact)

            speedPicker

            stepControls

            if !controller.checkpoints.isEmpty {
                checkpointControls
            }
        }
        .padding(14)
        .frame(width: 330)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.24), radius: 18, x: 0, y: 8)
        .accessibilityIdentifier("DebugTimeTravelControl")
    }

    private var header: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .imageScale(.medium)

            VStack(alignment: .leading, spacing: 2) {
                Text("Debug Time")
                    .font(.headline)
                Text(controller.now.formatted(date: .abbreviated, time: .standard))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .monospacedDigit()
            }

            Spacer()

            Button {
                controller.resetToRealTime()
            } label: {
                Image(systemName: "arrow.counterclockwise")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Reset debug time")

            Button {
                overlayState.isControlVisible = false
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Close debug time control")
        }
    }

    private var speedPicker: some View {
        Picker(
            "Speed",
            selection: Binding(
                get: { controller.selectedSpeedPreset },
                set: { controller.selectedSpeedPreset = $0 }
            )
        ) {
            ForEach(DebugTimeSpeedPreset.allCases) { preset in
                Text(preset.title).tag(preset)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityLabel("Debug time speed")
    }

    private var stepControls: some View {
        HStack(spacing: 8) {
            stepButton(title: "-15m", interval: -15 * 60)
            stepButton(title: "+15m", interval: 15 * 60)
            stepButton(title: "-1h", interval: -60 * 60)
            stepButton(title: "+1h", interval: 60 * 60)
            stepButton(title: "+1d", interval: 24 * 60 * 60)
        }
    }

    private func stepButton(title: String, interval: TimeInterval) -> some View {
        Button(title) {
            controller.step(by: interval)
        }
        .buttonStyle(.bordered)
        .font(.caption.weight(.semibold))
        .monospacedDigit()
    }

    private var checkpointControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Checkpoints")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 96), spacing: 8)], spacing: 8) {
                ForEach(controller.checkpoints) { checkpoint in
                    Button(checkpoint.title) {
                        controller.setDate(checkpoint.date)
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    .lineLimit(1)
                }
            }
        }
    }

}

#endif
