//
//  ChartSandbox.swift
//  Moers
//
//  Created by Lennart Fischer on 08.06.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI
//import Charts
//
//struct ToyShape: Identifiable {
//    var type: String
//    var count: Double
//    var id = UUID()
//}
//
//var data: [ToyShape] = [
//    .init(type: "Cube", count: 5),
//    .init(type: "Sphere", count: 4),
//    .init(type: "Pyramid", count: 4)
//]
//
//struct ParkingDatum: Hashable, Equatable {
//    let occupied: Int
//    let date: Date
//}
//
//let points = [
//    ParkingDatum(occupied: 120, date: Date().addingTimeInterval(.minutes(-1))),
//    ParkingDatum(occupied: 110, date: Date().addingTimeInterval(.minutes(-2))),
//    ParkingDatum(occupied: 102, date: Date().addingTimeInterval(.minutes(-5))),
//    ParkingDatum(occupied: 80, date: Date().addingTimeInterval(.minutes(-10))),
//    ParkingDatum(occupied: 92, date: Date().addingTimeInterval(.minutes(-14))),
//    ParkingDatum(occupied: 112, date: Date().addingTimeInterval(.minutes(-20))),
//    ParkingDatum(occupied: 130, date: Date().addingTimeInterval(.minutes(-30))),
//]
//
//@available(iOS 16.0, *)
//struct ChartSandbox: View {
//    var body: some View {
//        Chart() {
//            ForEach(points, id: \.self) { p in
//                PointMark(
//                    x: .value("Minute", p.date, unit: .minute),
//                    y: .value("", p.occupied)
//                )
//                LineMark(
//                    x: .value("Minute", p.date, unit: .minute),
//                    y: .value("", p.occupied)
//                )
//                .lineStyle(StrokeStyle(lineWidth: 3))
//                .interpolationMethod(.catmullRom)
//            }
//            .foregroundStyle(.blue)
//        }
//    }
//}
//
//@available(iOS 16.0, *)
//struct ChartSandbox_Previews: PreviewProvider {
//    static var previews: some View {
//        ChartSandbox()
//            .padding()
//            .frame(maxHeight: 400)
//            .previewLayout(.sizeThatFits)
//    }
//}
