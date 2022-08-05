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
                    
                    ForEach(viewModel.preferences, id: \.slug) { preference in
                        let checked: Bool = preference.value == "1"
                        let attributedString = preference.slug == "marketing-bink" ? AttributedString(L10n.preferencesMarketingCheckbox) : AttributedString(preference.label ?? "")
                        CheckboxSwiftUIView(checkedState: checked, attributedText: attributedString, columnName: preference.slug, columnKind: .add, delegate: viewModel, checkValidity: {})
//                        if preference.slug == AutofillUtil.slug {
//                            Current.userDefaults.set(checked, forDefaultsKey: .rememberMyDetails)
//                        }
                    }
                    
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
    
//    private func createCheckboxes(preferences: [PreferencesModel]) {
//        preferences.forEach {
//            let checked: Bool = $0.value == "1"
//            let checkboxView = CheckboxSwiftUIView(checkedState: checked, columnName: $0.slug, columnKind: .add, checkValidity: <#T##CheckValidity#>)
//            let attributedString = $0.slug == "marketing-bink" ?
//                NSMutableAttributedString(string: L10n.preferencesMarketingCheckbox, attributes: [.font: UIFont.bodyTextSmall]) :
//                NSMutableAttributedString(string: $0.label ?? "", attributes: [.font: UIFont.bodyTextSmall])
//            checkboxView.configure(title: attributedString, columnName: $0.slug ?? "", columnKind: .add, delegate: self)
//
//            if $0.slug == AutofillUtil.slug {
//                Current.userDefaults.set(checked, forDefaultsKey: .rememberMyDetails)
//            }
//        }
//    }
    
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView(viewModel: PreferencesViewModel())
    }
}
