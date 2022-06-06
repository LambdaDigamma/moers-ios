//
//  WallOfContribution.swift
//  Moers
//
//  Created by Lennart Fischer on 29.05.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI

public struct Contribution: Codable, Equatable, Hashable, Identifiable {
    
    public let id: UUID
    public let text: String
    
    public init(
        text: String
    ) {
        self.id = UUID()
        self.text = text
    }
    
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

public struct WallOfContribution: View {
    
    private let startAnimationDuration = 5.0
    @State private var animationStart = false
    
    @State var position = 0.0
    
    public var body: some View {
        
        Coverflow()
        
//        ScrollView {
//            ZStack {
//                LazyVStack {
//                    ForEach(0...100, id: \.self) { index in
//                        Text("Row \(index)")
//                    }
//                }
//                Text("\(position)")
//                GeometryReader { proxy in
//                    let offset = proxy.frame(in: .named("scroll")).minY
//                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
//                }
//            }
//        }
//        .coordinateSpace(name: "scroll")
//        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
//            position = value
////            print(value)
//        }
        
//        ScrollView {
//
//            ScrollViewReader { proxy in
//
//                VStack {
//
//                    Text("Lennart Fischer")
//                    Text("Simon Jäschke")
//                    Text("Simon Krenz")
//
////                    Text(proxy)
//
//                    proxy.
//
//                }
//                .rotation3DEffect(.degrees(45), axis: (x: 10, y: 0, z: 0))
//
//            }
//
//        }
//        .padding(.top, 80)
        
        
//        GeometryReader { geometry in
//            Text("A long time ago, in a galaxy far, far away... It is a period of civil war. Rebel spaceships, striking from a hidden base, have won their first victory against the evil Galactic Empire.")
//                .fontWeight(.black)
//                .font(Font.custom("System", size: 28))
//                .foregroundColor(.yellow)
//                .multilineTextAlignment(.center)
//                .lineSpacing(10)
//                .padding()
//                .rotation3DEffect(.degrees(45), axis: (x:10, y:0, z:0))
//                .frame(width: 300, height: self.animationStart ? geometry.size.height : 0)
//                .animation(Animation.linear(duration: self.startAnimationDuration))
//                .onAppear() {
//                    self.animationStart.toggle()
//                }
//        }
    }
    
//    private let startAnimationDuration = 11.0
//    private let endAnimationDuration = 1.5
//
//    @State private var animationStart = false
//    @State private var animationEnd = false
//
//    public var body: some View {
//
//        VStack(alignment: .leading) {
//
//            Text("Wall of Contribution")
//                .font(.system(.largeTitle, design: .rounded))
//                .fontWeight(.semibold)
//                .padding()
//                .frame(maxWidth: .infinity, alignment: .center)
//
//            Divider()
//
//            section(
//                header: "General",
//                contributions: [
//                    Contribution(text: "Lennart Fischer"),
//                    Contribution(text: "Simon Jäschke"),
//                    Contribution(text: "Simon Krenz"),
//                ]
//            )
//
//            section(
//                header: "General",
//                contributions: [
//
//                ]
//            )
//
//        }
//        .frame(maxWidth: .infinity)
//        .rotation3DEffect(.degrees(animationEnd ? 0 : 60), axis: (x: 1, y: 0, z: 0))
////        .shadow(color: .gray, radius: 2, x: 0, y: 15)
//        .frame(width: 300, height: animationStart ? 750 : 0)
//        .animation(Animation.linear(duration: animationEnd ? endAnimationDuration : startAnimationDuration))
//        .onAppear {
//            self.animationStart.toggle()
//            DispatchQueue.main.asyncAfter(deadline: .now() + self.startAnimationDuration) {
//                self.animationEnd.toggle()
//            }
//        }
//
//    }
    
    @ViewBuilder
    private func section(
        header: String,
        contributions: [Contribution]
    ) -> some View {
        
        VStack {
            
            Text(header)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            VStack {
                
                ForEach(contributions) { (contribution: Contribution) in
                    
                    Text(contribution.text)
                    
                }
                
            }
            
            Divider()
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct Coverflow: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(1..<20) { num in
                    GeometryReader { geo in
                        
                        
                        
                        Text("Name \(num)")
                            .font(.largeTitle)
                            .padding()
//                            .rotation3DEffect(
//                                .degrees(-geo.frame(in: .global).minY) / 8,
//                                axis: (x: 0, y: 1, z: 0)
//                            )
                            .rotation3DEffect(
                                .degrees(50),
                                axis: (x: 1, y: 0, z: 0)
                            )
//                            .scaleEffect(1 / )
                            .frame(width: 200, height: 100)
                    }
                    .frame(width: 200, height: 100)
                }
            }
        }
    }
}

struct WallOfContribution_Previews: PreviewProvider {
    static var previews: some View {
        WallOfContribution()
            .previewLayout(.sizeThatFits)
    }
}
