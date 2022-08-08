//
//  PreferencesView.swift
//  binkapp
//
//  Created by Sean Williams on 04/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @ObservedObject var viewModel: PreferencesViewModel
        
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
                        .padding(.bottom, 15)
                    
                    ForEach(viewModel.checkboxViewModels, id: \.columnName) { viewModel in
                        CheckboxSwiftUIView(viewModel: viewModel) {
                            self.viewModel.checkboxViewWasToggled(viewModel)
                        }
                        .padding(.bottom, 15)
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Button {
                        viewModel.clearStoredCredentials()
                    } label: {
                        Text(L10n.preferencesClearCredentialsTitle)
                            .font(.custom(UIFont.linkUnderlined.fontName, size: UIFont.linkUnderlined.pointSize))
                            .foregroundColor(Color(UIColor.blueAccent))
                            .underline()
                    }
                    .padding(.bottom, 15)

                    if let errorText = viewModel.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                .onAppear {
                    viewModel.getPreferences()
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
