//
//  EntryValidationCellView.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import SwiftUI

struct EntryValidationCellView: View {
    let image: UIImage?
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 8) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 40, minHeight: 40)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

#Preview {
    EntryValidationCellView(
        image: UIImage(systemName: "checkmark.circle"),
        title: "Sample Entry",
        description: "This is a validation entry"
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
