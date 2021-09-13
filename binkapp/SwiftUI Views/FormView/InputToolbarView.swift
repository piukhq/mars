//
//  InputToolbarView.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct InputToolbarView: View {
    var buttonAction: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: 0.5)
            HStack {
                Spacer()
                Button(L10n.done) {
                    buttonAction()
                }
                .foregroundColor(Color(.binkGradientBlueLeft))
                .padding(.trailing, 12)
            }
            .frame(idealWidth: .infinity, maxWidth: .infinity, idealHeight: 44, maxHeight: 44, alignment: .center)
            .background(Color.white)
        }
    }
}
