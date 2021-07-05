//
//  UnauthenticatedSwiftUIView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 22/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct UnauthenticatedSwiftUIView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("bink-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 140.0)
            Spacer()
                .frame(width: 68.0)
            Text("Tap to sign in\n to Bink")
                .font(.system(size: 12))
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 20.0)
        .background(Color("UnAuthWidgetBackground"))
    }
}
