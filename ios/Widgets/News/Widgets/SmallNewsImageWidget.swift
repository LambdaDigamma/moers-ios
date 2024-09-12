//
//  SmallNewsImageWidget.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
//import NewsWidgets

struct SmallNewsImageWidget: View {
    
    public let viewModel: NewsViewModel
    
    public init(viewModel: NewsViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ImageNewsView(viewModel: viewModel)
            .widgetURL(viewModel.link)
    }
    
}

struct SmallNewsImageWidget_Previews: PreviewProvider {
    static var previews: some View {
        SmallNewsImageWidget(viewModel: NewsViewModel.mocked[0])
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
