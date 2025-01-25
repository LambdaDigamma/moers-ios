//
//  TripPartialRoutesPager.swift
//  
//
//  Created by Lennart Fischer on 16.12.22.
//

import SwiftUI

struct TripPartialRoutesPager: View {
    
    var body: some View {
        
        TabView {
            
            TrackChangeView(data: TrackChangeData(
                fromTrack: TripPartialRouteTrack(name: "1"),
                toTrack: TripPartialRouteTrack(name: "14A"),
                currentChangeTime: .init(value: 6, unit: .minutes)
            ))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            HStack {
                Text("DEF")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue)
            
        }
        .background(Color(UIColor.secondarySystemBackground))
        .frame(maxWidth: .infinity, maxHeight: 220)
        .tabViewStyle(.page(indexDisplayMode: .always))
        
    }
    
    @ViewBuilder
    func changeTrack(
        from fromTrack: TripPartialRouteTrack,
        to toTrack: TripPartialRouteTrack
    ) -> some View {
        
        VStack(alignment: .leading) {
            Text("\(Image(systemName: "shuffle")) Gleiswechsel")
                .fontWeight(.semibold)
                .foregroundColor(.yellow)
            
            HStack(spacing: 32) {
                
                trackInfo(name: fromTrack.name)
                
                Image(systemName: "arrow.right")
                    .font(.largeTitle.weight(.semibold))
                
                trackInfo(name: toTrack.name)
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
//            .padding(.bottom, 20)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            
            VStack(alignment: .center) {
                Text("aktuelle Umsteigszeit: \(10) min")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        
    }
    
    @ViewBuilder
    func trackInfo(name: String) -> some View {
        
        Text(name)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .frame(minWidth: 80, idealWidth: 50)
            .background(Color(UIColor.tertiarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: 8))
//            .font(Font.system(.largeTitle, design: SwiftUI.Font.Design.rounded))
            .font(.largeTitle.weight(.semibold))
        
    }
    
    
}

struct TripPartialRoutesPager_Previews: PreviewProvider {
    static var previews: some View {
        TripPartialRoutesPager()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
