//
//  TagCellView.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import SwiftUI

struct TagCellView: View {
    let title: String
    
    var body: some View {
        Text(title)
            .foregroundColor(.primary)
    }
}

#Preview {
    TagCellView(title: "Sample Tag")
}
