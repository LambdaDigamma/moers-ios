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
        
        HStack(spacing: 12) {
            
            LocationTypeIcon(
                backgroundColor: Color.blue,
                foregroundColor: Color.white
            )
            .aspectRatio(contentMode: .fit)
            .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
        }
        .padding(.vertical, 8)
        .padding(.leading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.clear)
        
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
}
