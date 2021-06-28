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
                .padding(.all, 19.0)
            Text("Tap to sign in to Bink")
                .font(.system(size: 12))
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
                .padding(.horizontal, 16.0)
        }
        .padding(.vertical, 9.0)
        .background(Color("UnAuthWidgetBackground"))
    }
}

//struct UnauthenticatedSwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        UnauthenticatedSwiftUIView()
//    }
//}
