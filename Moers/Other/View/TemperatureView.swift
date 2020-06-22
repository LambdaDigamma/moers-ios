//
//  TemperatureView.swift
//  Moers
//
//  Created by Lennart Fischer on 01.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct TemperatureView: View {
    var body: some View {
        MultiLineChartView(
            data: [
                ([0,1,2,3,4,5,6], GradientColors.green),
                ([90,99,78,111,70,60,77], GradientColors.purple),
                ([34,56,72,38,43,100,50], GradientColors.orngPink)
            ],
            title: "Temperatur")
    }
}

@available(iOS 13.0, *)
struct TemperatureView_Previews: PreviewProvider {
    static var previews: some View {
        TemperatureView()
    }
}
