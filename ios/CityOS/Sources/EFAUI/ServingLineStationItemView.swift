//
//  ServingLineStationItemView.swift
//  
//
//  Created by Lennart Fischer on 09.12.21.
//

import SwiftUI

public struct ServingLineStationViewModel: Equatable {
    public var stationName: String
    public var date: Date?
    public var delay: Int?
}

public struct ServingLineStationItemView: View {
    
    @ScaledMetric public var circleSize: CGFloat = 20
    @ScaledMetric public var lineWidth: CGFloat = 4
    @ScaledMetric public var laneWidth: CGFloat = 60
    
    public var viewModel: ServingLineStationViewModel
    public var indicatorColor: Color = Color.accentColor
    
    public init(
        viewModel: ServingLineStationViewModel,
        indicatorColor: Color = Color.accentColor
    ) {
        self.viewModel = viewModel
        self.indicatorColor = indicatorColor
    }
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                
                ZStack(alignment: .top) {
                }
                .frame(width: laneWidth, alignment: .center)
                
                HStack {
                    VStack(alignment: .leading) {
                        Text(viewModel.stationName)
                            .fontWeight(.semibold)
                        if let date = viewModel.date {
                            Text(date, style: Text.DateStyle.time)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 16)
                .padding(.trailing, 16)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(lineBackground())
        
    }
    
    @ViewBuilder
    func lineBackground() -> some View {
        HStack {
            ZStack(alignment: .top) {
                Rectangle()
                    .frame(maxWidth: lineWidth)
                Circle()
                    .strokeBorder(indicatorColor, style: StrokeStyle(lineWidth: lineWidth))
                    .background(Color.white)
                    .frame(width: circleSize, height: circleSize, alignment: .top)
                    .offset(y: 16)
            }
            .foregroundColor(indicatorColor)
            .frame(width: laneWidth, alignment: .center)
            
            Spacer()
        }
        
    }
    
}

struct ServingLineStationItemView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let station1 = ServingLineStationViewModel(
            stationName: "Königlicher Hof",
            date: .init(timeIntervalSinceNow: 60 * 5)
        )
        
        let station2 = ServingLineStationViewModel(
            stationName: "Musterstraße",
            date: .init(timeIntervalSinceNow: 60 * 10)
        )
        
        Group {
            ServingLineStationItemView(
                viewModel: station1,
                indicatorColor: Color.blue
            )
                .previewLayout(.sizeThatFits)
            
            VStack(alignment: .leading, spacing: 0) {
                ServingLineStationItemView(viewModel: station1)
                ServingLineStationItemView(viewModel: station2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .previewLayout(.sizeThatFits)
            
        }
        
    }
    
}
