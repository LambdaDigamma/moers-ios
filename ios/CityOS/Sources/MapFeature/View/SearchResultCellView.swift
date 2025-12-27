//
//  SearchResultCellView.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import SwiftUI

struct SearchResultCellView: View {
    let image: UIImage?
    let title: String
    let subtitle: String
    let showCheckmark: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if showCheckmark {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    SearchResultCellView(
        image: UIImage(systemName: "mappin"),
        title: "Sample Location",
        subtitle: "123 Main St",
        showCheckmark: true
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
