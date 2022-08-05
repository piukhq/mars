//
//  PreferencesView.swift
//  binkapp
//
//  Created by Sean Williams on 04/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    let viewModel: PreferencesViewModel
    
    @State private var errorText = ""

    var body: some View {
        ScrollView {
            HStack {
                VStack(alignment: .leading) {
                    Text(L10n.settingsRowPreferencesTitle)
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        .font(.custom(UIFont.headline.fontName, size: UIFont.headline.pointSize))

                    Text(viewModel.descriptionText)
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        .font(.custom(UIFont.bodyTextLarge.fontName, size: UIFont.bodyTextLarge.pointSize))
                    
                    Spacer()
                        .frame(height: 30)
                    
                    Button {
                        viewModel.clearStoredCredentials()
                    } label: {
                        Text(L10n.preferencesClearCredentialsTitle)
                            .font(.custom(UIFont.linkUnderlined.fontName, size: UIFont.linkUnderlined.pointSize))
                            .foregroundColor(Color(UIColor.blueAccent))
                            .underline()
                    }
                    .padding(.bottom, 15)

                    
                    Text(errorText)
                        .foregroundColor(.red)
                        .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .onAppear {
                    viewModel.getPreferences(onSuccess: { (preferences) in
                        print(preferences)
                    }) {
                        errorText = L10n.preferencesRetrieveFail
                    }
                }
                
                Spacer()
            }
        }
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(viewModel: PreferencesViewModel())
    }
}
