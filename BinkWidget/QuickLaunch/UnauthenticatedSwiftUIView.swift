//
//  UnauthenticatedSwiftUIView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 22/06/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct UnauthenticatedSwiftUIView: View {
    enum Constants {
        static let ImageWidth: CGFloat = 140.0
        static let SpacerWidth: CGFloat = 68.0
        static let VerticalPadding: CGFloat = 20.0
        static let TextSize: CGFloat = 12.0
    }
    
    var body: some View {
            HStack(alignment: .center, spacing: 0) {
                Image("bink-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.ImageWidth)
                Spacer()
                    .frame(width: Constants.SpacerWidth)
                Text("Tap to sign in\n to Bink")
                    .font(.system(size: Constants.TextSize))
                    .fontWeight(.medium)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, Constants.VerticalPadding)
            .background(Color("UnAuthWidgetBackground"))
            .widgetURL(URL(string: "quicklaunch-widget://sign_in"))
    }
}
