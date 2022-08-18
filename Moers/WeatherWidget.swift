//
//  WeatherWidget.swift
//  
//
//  Created by Lennart Fischer on 08.06.22.
//

import SwiftUI
import Core
//import WeatherKit
import CoreLocation

//@available(iOS 16.0, *)
//class WeatherViewModel: StandardViewModel {
//
//    let service = WeatherService.shared
//
//    @Published var weather: DataState<Weather, Error> = .loading
//
//    public func load() async {
//
//        let location = CLLocation(latitude: 51.450717, longitude: 6.620537)
//
//        do {
//
//            let weather = try await service.weather(for: location)
//
//            self.weather = .success(weather)
//
//        } catch {
//            self.weather = .error(error)
//        }
//
//    }
//
//}
//
//@available(iOS 16.0, *)
//struct WeatherWidget: View {
//
//    @StateObject var viewModel = WeatherViewModel()
//
//    var body: some View {
//
//        VStack {
//
//            viewModel.weather.isLoading {
//                ProgressView()
//                    .progressViewStyle(.circular)
//            }
//
//            viewModel.weather.hasResource { (weather: Weather) in
//
//                Text(weather.currentWeather.temperature.formatted())
//
//            }
//
//            viewModel.weather.hasError { (error: Error) in
//                if let error = error as? WeatherError {
//                    Text(error.helpAnchor ?? "")
//                } else {
//                    Text(error.localizedDescription)
//                }
//            }
//
//        }
//        .padding(12)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .task {
//            await viewModel.load()
//        }
//
//    }
//}
//
//@available(iOS 16.0, *)
//struct WeatherWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        WeatherWidget()
//            .padding()
//            .previewLayout(.sizeThatFits)
//    }
//}
