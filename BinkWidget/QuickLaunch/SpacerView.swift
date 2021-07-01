//
//  SpacerView.swift
//  BinkWidgetExtension
//
//  Created by Sean Williams on 01/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct SpacerView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Spacer().frame(width: 20, height: 36, alignment: .center)
        }
        .padding(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
        .background(
            RoundedRectangle(cornerRadius: 12.0)
                .foregroundColor(Color(.clear))
        )
    }
}
