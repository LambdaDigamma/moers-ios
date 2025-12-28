//
//  ParkingAreaDetail.swift
//  
//
//  Created by Lennart Fischer on 10.01.22.
//

import Core
import SwiftUI

struct BlurModifier: ViewModifier {
    @Binding var showOverlay: Bool
    @State var blurRadius: CGFloat = 4
    
    func body(content: Content) -> some View {
        Group {
            content
                .blur(radius: showOverlay ? blurRadius : 0)
        }
    }
}

public struct ParkingAreaDetail: View {
    
    private let name: String
    private let total: Int
    private let free: Int
    private let updatedAt: Date
    private let openingState: ParkingAreaOpeningState
    
    private var showsOverlay: Bool {
        return openingState == .closed
            || openingState == .unknown
    }
    
    private var freePercent: Double {
        
        if total <= 0 {
            return 1
        }
        
        return 1 - Double(free) / Double(total)
        
    }
    
    public init(viewModel: ParkingAreaViewModel) {
        self.name = viewModel.title
        self.free = viewModel.free
        self.total = viewModel.total
        self.openingState = viewModel.currentOpeningState
        self.updatedAt = viewModel.updatedAt
    }
    
    public init(
        name: String,
        total: Int,
        free: Int,
        openingState: ParkingAreaOpeningState = .open
    ) {
        self.name = name
        self.free = free
        self.total = total
        self.openingState = openingState
        self.updatedAt = Date()
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack {
                
                Text(name)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
            }
            
            VStack(alignment: .leading, spacing: 0) {
                
                VStack(alignment: .leading) {
                    
                    HStack(alignment: .firstTextBaseline) {
                        
                        Text("\(free)", bundle: .module)
                            .font(.title2.weight(.bold))
                        
                        +
                        
                        Text(" / \(total) free", bundle: .module)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                    }
                    
                    Spacer()
                        .frame(maxHeight: 16)
                    
                }
                .padding(.bottom, 8)
                
                VStack(alignment: .leading) {
                    
                    ProgressMeterView(
                        value: freePercent,
                        color: .gray
                    )
                    
                    Text(updatedAt, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                }
                
            }
            .frame(maxWidth: .infinity)
            .modifier(BlurModifier(showOverlay: .constant(showsOverlay)))
            .overlay(overlayIfNeeded())
            
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func overlayIfNeeded() -> some View {
        
        if openingState.isNegativeState {
            ZStack {
                Text(openingState.name)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(openingState.badgeColor)
                    .cornerRadius(4)
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            EmptyView()
        }
        
    }
    
}

struct SmallParkingDashboarding_Previews: PreviewProvider {
    static var previews: some View {
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34, openingState: .closed)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .frame(maxWidth: 160)
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34, openingState: .unknown)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .frame(maxWidth: 160)
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .redacted(reason: .placeholder)
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .frame(maxWidth: 200)
        
    }
}
