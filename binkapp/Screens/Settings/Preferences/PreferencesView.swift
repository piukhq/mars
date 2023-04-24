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
                        .uiFont(.headline)

                    Text(viewModel.descriptionText)
                        .foregroundColor(Color(Current.themeManager.color(for: .text)))
                        .uiFont(.bodyTextLarge)
                        .padding(.bottom, 15)
                    
                    if viewModel.checkboxViewModels.isEmpty {
                        HStack(alignment: .center, spacing: 30) {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(Current.themeManager.color(for: .text))))
                                .scaleEffect(2.0, anchor: .center)
                            Spacer()
                        }
                        .padding(20)
                    } else {
                        ForEach(viewModel.checkboxViewModels, id: \.columnName) { viewModel in
                            CheckboxSwiftUIView(viewModel: viewModel) {
                                self.viewModel.checkboxViewWasToggled(viewModel)
                            }
                            .padding(.bottom, 15)
                        }
                    }
                    
                    Spacer()
                        .frame(height: 20)
                    
                    Button {
                        viewModel.clearStoredCredentials()
                    } label: {
                        Text(L10n.preferencesClearCredentialsTitle)
                            .underline()
                            .uiFont(.linkUnderlined)
                            .foregroundColor(Color(UIColor.binkBlue))
                    }
                    .padding(.bottom, 15)

                    if let errorText = viewModel.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .uiFont(.bodyTextSmall)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
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
