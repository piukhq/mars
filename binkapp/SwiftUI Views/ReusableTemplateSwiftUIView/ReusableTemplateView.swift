//
//  ReusableTemplateView.swift
//  binkapp
//
//  Created by Sean Williams on 03/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct ReusableTemplateView: View {
    let title: String
    let description: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(title)
                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))

                Text(description)
                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
            }
            .padding(.horizontal, 25)
            .padding(.top, 20)
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct ReusableTemplateView_Previews: PreviewProvider {
    static var previews: some View {
        ReusableTemplateView(title: L10n.securityAndPrivacyTitle, description: L10n.securityAndPrivacyDescription)
    }
}
