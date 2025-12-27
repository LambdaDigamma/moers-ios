//
//  TripSearchScreen.swift
//  
//
//  Created by Lennart Fischer on 04.04.22.
//

import SwiftUI
import EFAAPI
import Combine
import ModernNetworking

public struct TripSearchScreen: View {
    
    @ObservedObject var viewModel: TripSearchViewModel
    @State var showConfiguration: Bool = false
    
    public init(
        viewModel: TripSearchViewModel
    ) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            topInfoBar()
            
            Divider()
            
            emptyState()
            valueState()
            errorState()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(Text("Verbindungen"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            viewModel.search()
        }
        .sheet(isPresented: $showConfiguration) {
            TripConfigurationSheet()
        }
        
    }
    
    @ViewBuilder
    private func topInfoBar() -> some View {
        
        let dateTime = viewModel.result.value?.tripDateTime.dateTime.parsedDate ?? Date()
        let depArrType = viewModel.result.value?.tripDateTime.depArrType ?? .departure
        
        let modePlaceholder = viewModel.result.value == nil
        let widthInset: Double = 68
        
        VStack(alignment: .leading, spacing: 12) {
            
            VStack(spacing: 4) {
                
                HStack {
                    
                    Text("Von:")
                        .foregroundColor(.secondary)
                        .frame(width: widthInset, alignment: .leading)
                    
//                    Spacer()
                    
                    Text(viewModel.origin?.name ?? "")
                        .lineLimit(1)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    
                    Text("Nach:")
                        .foregroundColor(.secondary)
                        .frame(width: widthInset, alignment: .leading)
                    
//                    Spacer()
                    
                    Text(viewModel.destination?.name ?? "")
                        .lineLimit(1)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .font(.callout.weight(.medium))
            .foregroundColor(Color.primary)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(UIColor.tertiarySystemFill))
            .cornerRadius(8)
            
//            HStack {
//
//                Text("Von:")
//                    .frame(width: 50, alignment: .leading)
//
//                Spacer()
//
//                Text(viewModel.origin?.name ?? "")
//
//            }
//            .font(.callout.weight(.semibold))
//            .padding(.horizontal, 12)
//
//            HStack {
//
//                Text("Nach:")
//                    .frame(width: 50, alignment: .leading)
//
//                Spacer()
//
//                Text(viewModel.destination?.name ?? "")
//
//            }
//            .font(.callout.weight(.semibold))
//            .padding(.horizontal, 12)
            
            Button(action: {
                showConfiguration = true
            }) {
                
                HStack {
                    Text("\(depArrType.localized):")
                        .foregroundColor(.secondary)
                        .frame(width: widthInset, alignment: .leading)
                    
//                    Spacer()
                    
                    Text("\(dateTime, style: .date)") + Text(" ") +
                    Text("\(dateTime, style: .time)")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.callout.weight(.medium))
                .redacted(reason: modePlaceholder ? [.placeholder] : [])
                .foregroundColor(Color.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(UIColor.tertiarySystemFill))
                .cornerRadius(8)
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        
    }
    
    @ViewBuilder
    private func emptyState() -> some View {
        
        viewModel.result.isEmpty() {
            
            ZStack {
                Text(String(localized: "Start your search", bundle: .module))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        
    }
    
    @ViewBuilder
    private func loadingState() -> some View {
        
        viewModel.result.isLoading {
            
            ZStack {
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func valueState() -> some View {
        
        viewModel.result.hasResource { (request: TripRequest) in
            
            ScrollView {
                
                VStack(spacing: 12) {
                    
                    ForEach(request.itinerary.safeRoutes) { route in
                        
                        NavigationLink {
                            TripDetailScreen(
                                route: route.transformIntoUiState(
                                    origin: viewModel.origin?.name ?? "",
                                    destination: viewModel.destination?.name ?? ""
                                ),
                                onActivateRoute: {
                                    viewModel.activate(route: route, for: request)
                                }
                            )
                        } label: {
                            row(route: route)
                        }
                        
                    }
                    
                }
                .padding()
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func errorState() -> some View {
        
        viewModel.result.hasError { (error: Error) in
            Text(error.localizedDescription)
        }
        
    }
    
    @ViewBuilder
    private func row(route: ITDRoute) -> some View {
        
        TripRouteOverview(route: route)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        
    }
    
}

public struct TripRouteOverview: View {
    
    public let route: ITDRoute
    let columns = [
        GridItem(.adaptive(minimum: 42), alignment: .leading)
    ]
    
    public init(route: ITDRoute) {
        self.route = route
    }
    
    public var body: some View {
        
        newBody
        
    }
    
    public var oldBody: some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .top) {
                
                VStack {
                    
                    if let startDate = route.targetStartDate, let endDate = route.targetEndDate {
                        Text(Self.shortIntervalFormatter.string(from: startDate, to: endDate))
                    }
                    
                    if let startDate = route.realtimeStartDate, let endDate = route.realtimeEndDate {
                        Text(Self.shortIntervalFormatter.string(from: startDate, to: endDate))
                            .foregroundColor(.green)
                    }
                    
                }
                .font(.caption)
                
                Text("\(route.publicDuration)")
                
                Spacer()
                
                Text("Umst. \(route.numberOfChanges)")
                
            }
            .font(.caption)
            
            VStack(alignment: .leading) {
                
                ForEach(route.partialRouteList.partialRoutes, id: \.self) { partialRoute in
                    
                    HStack {
                        
                        if let type = partialRoute.meansOfTransport.motType {
                            
                            HStack {
                                TransportIcon.icon(for: type)
                                Text("\(partialRoute.meansOfTransport.shortName)")
                            }
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(8)
                            .font(.footnote.weight(.semibold))
                            
                        } else {
                            
                            HStack {
                                TransportIcon.pedestrian()
                            }
                            .foregroundColor(Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(UIColor.secondarySystemFill))
                            .cornerRadius(8)
                            .font(.footnote.weight(.semibold))
                            
                        }
                        
                        if let origin = partialRoute.points.first, let destination = partialRoute.points.last {
                            Text("\(origin.name)")
                                .font(.footnote.weight(.semibold))
                            + Text(" \(Image(systemName: "arrow.right")) ") + Text("\(destination.name)")
                                .font(.footnote.weight(.semibold))
                        }
                        
//                                if let destination = partialRoute.points.last {
//                                    Text("\(destination.name)")
//                                        .font(.footnote.weight(.semibold))
//                                }
                        
                    }
                    
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
        }
        
    }
    
    public var newBody: some View {
        
        VStack(alignment: .leading) {
            
            HStack(alignment: .top, spacing: 20) {
                
                VStack {
                    
                    if let target = route.targetStartDate, let realtime = route.realtimeStartDate {
                        
                        if target == realtime {
                            Text(Self.shortTimeFormatter.string(from: target))
                                .foregroundColor(.primary)
                        } else {
                            Text(Self.shortTimeFormatter.string(from: target))
                                .foregroundColor(.primary)
                            Text(Self.shortTimeFormatter.string(from: realtime))
                                .foregroundColor(.green)
                        }
                        
                    }
                    
                }
                .font(.callout.weight(.semibold))
                
                VStack {
                    
                    HStack {
                        
                        Circle()
                            .fill(Color(UIColor.secondaryLabel))
                            .frame(width: 4, height: 4)
                        
                        Spacer()
                        
                        Text("\(route.publicDuration)h")
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal, 8)
                            .background(Color(UIColor.secondarySystemBackground))
                        
                        Spacer()
                        
                        Circle()
                            .fill(Color(UIColor.secondaryLabel))
                            .frame(width: 4, height: 4)
                        
                    }
                    .background(ZStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(UIColor.tertiarySystemFill))
                            .frame(height: 2)
                    })
                    
                    Text("\(route.numberOfChanges) Umstiege")
                        .foregroundColor(.secondary)
                        .font(.caption.weight(.medium))
                    
                }
                
                VStack {
                    
                    if let target = route.targetEndDate, let realtime = route.realtimeEndDate {
                        
                        if target == realtime {
                            Text(Self.shortTimeFormatter.string(from: target))
                                .foregroundColor(.primary)
                        } else {
                            Text(Self.shortTimeFormatter.string(from: target))
                                .foregroundColor(.primary)
                            Text(Self.shortTimeFormatter.string(from: realtime))
                                .foregroundColor(.green)
                        }
                        
                    }
                    
                }
                .font(.callout.weight(.semibold))
                
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                HStack {
                    
                    ForEach(route.partialRouteList.partialRoutes, id: \.self) { partialRoute in
                        
                        HStack {
                            
                            if let type = partialRoute.meansOfTransport.motType {
                                
                                HStack {
                                    TransportIcon.icon(for: type).resizable()
                                    Text("\(partialRoute.meansOfTransport.shortName)")
                                }
                                .foregroundColor(Color.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(UIColor.secondarySystemFill))
                                .cornerRadius(8)
                                .font(.caption.weight(.semibold))
                                
                            } else {
                                
                                HStack {
                                    TransportIcon.pedestrian().resizable()
                                }
                                .foregroundColor(Color.secondary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(UIColor.secondarySystemFill))
                                .cornerRadius(8)
                                .font(.caption.weight(.semibold))
                                
                            }
                            
                        }
                        
                    }
                    
                }
                
            }
            
//            LazyVGrid(columns: columns, alignment: .leading, spacing: 10) {
//
//                ForEach(route.partialRouteList.partialRoutes, id: \.self) { partialRoute in
//
//                    HStack {
//
//                        if let type = partialRoute.meansOfTransport.motType {
//
//                            HStack {
//                                TransportIcon.icon(for: type)
//                                Text("\(partialRoute.meansOfTransport.shortName)")
//                            }
//                            .foregroundColor(Color.white)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color(UIColor.secondarySystemFill))
//                            .cornerRadius(8)
//                            .font(.footnote.weight(.semibold))
//
//                        } else {
//
//                            HStack {
//                                TransportIcon.pedestrian()
//                            }
//                            .foregroundColor(Color.white)
//                            .padding(.horizontal, 8)
//                            .padding(.vertical, 4)
//                            .background(Color(UIColor.secondarySystemFill))
//                            .cornerRadius(8)
//                            .font(.footnote.weight(.semibold))
//
//                        }
//
//                    }
//
//                }
//
//            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    public static let shortIntervalFormatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
    public static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    
}


struct TripSearchResultsScreen_Previews: PreviewProvider {
    static var previews: some View {
        
        let service = DefaultTransitService(loader: DefaultTransitService.defaultLoader())
        let viewModel = TripSearchViewModel(
            transitService: service,
            originID: "streetID:1500000920:13:5116000:-1:Königstraße:Mönchengladbach:Königstraße::Königstraße:41236:ANY:DIVA_SINGLEHOUSE:717845:5349344:MRCV:nrw",
            destinationID: "streetID:1500000264:55:5334002:-1:Ahornstraße:Aachen:Ahornstraße::Ahornstraße:52074:ANY:DIVA_SINGLEHOUSE:674518:5417636:MRCV:nrw"
        )
        
        viewModel.origin = TransitLocation(
            name: "Mönchengladbach, Königstraße 13",
            description: ""
        )
        
        viewModel.destination = TransitLocation(
            name: "Aachen, Ahornstraße 55",
            description: ""
        )
        
        return NavigationView {
            TripSearchScreen(viewModel: viewModel)
        }.preferredColorScheme(.dark)
        
    }
}
