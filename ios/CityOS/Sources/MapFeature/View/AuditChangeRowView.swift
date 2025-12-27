//
//  AuditChangeRowView.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import SwiftUI

struct AuditChangeRowView: View {
    let valueDescription: String
    let oldValue: String
    let newValue: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
                
                Text(valueDescription)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .fixedSize()
                
                Rectangle()
                    .fill(Color.secondary.opacity(0.3))
                    .frame(height: 1)
            }
            
            HStack(spacing: 0) {
                Text(newValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(oldValue)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }
}

#Preview {
    AuditChangeRowView(
        valueDescription: "Name",
        oldValue: "Old Name",
        newValue: "New Name"
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
