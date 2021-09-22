//
//  AttributedTextView.swift
//  binkapp
//
//  Created by Sean Williams on 22/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct AttributedTextView: View {
    var viewModel: FormViewModel
    
    var body: some View {
        if case .login(let loginType) = viewModel.datasource.formtype {
            if loginType == .magicLink {
                HStack(spacing: 4) {
                    Text(L10n.magicLinkDescriptionNoteHighlight)
                        .font(.nunitoExtraBold(18))
                    Text(L10n.magicLinkDescriptionHyperlinkBody)
                        .font(.nunitoLight(18))
                    Button {
                        viewModel.toMagicLinkModal()
                    } label: {
                        Text(L10n.whatIsMagicLinkHyperlink)
                            .font(.nunitoLight(18))
                            .foregroundColor(Color(.binkGradientBlueLeft))
                            .underline()
                    }
                    Spacer()
                }
                .padding(.horizontal, 5)
            }
        }
    }
}
