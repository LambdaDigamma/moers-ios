//
//  AuthorView.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import SwiftUI
import MMCommon

struct AuthorView: View {
    var body: some View {
        HStack {
            Image("jazzthetik")
                .resizable()
                .aspectRatio(1, contentMode: .fill)
                .clipShape(Circle())
                .frame(width: 40, height: 40, alignment: .center)
            VStack(alignment: .leading) {
                Text("Tim Isfort")
                    .font(Typography.style(.custom(size: 14, weight: .medium)))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                Text("vor einer Stunde")
                    .font(Typography.style(.custom(size: 10, weight: .regular)))
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondaryLabel)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AuthorView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorView()
            .environment(\.colorScheme, .dark)
    }
}
