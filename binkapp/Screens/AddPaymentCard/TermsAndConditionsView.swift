//
//  TermsAndConditionsView.swift
//  binkapp
//
//  Created by Sean Williams on 17/03/2023.
//  Copyright © 2023 Bink. All rights reserved.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var viewModel = TermsAndConditionsViewModel()
    var body: some View {
        VStack {
            HStack {
                Text(L10n.termsAndConditionsTitle)
                    .uiFont(.headline)
                    .padding(.leading, 25)
                 Spacer()
            }
            Text(viewModel.termsAndConditionsDescription)
                .uiFont(.bodyTextLarge)
                .padding(.horizontal, 25)
                .minimumScaleFactor(0.5)
            
            BinkButtonsStackView(buttons: [viewModel.iAcceptButton, viewModel.iDeclineButton])
        }
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}

class TermsAndConditionsViewModel {
    lazy var iAcceptButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.iAccept), alwaysEnabled: true, buttonTapped: {
            Current.navigate.close {}
        }, type: .gradient)
    }()
    
    lazy var iDeclineButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.iDecline), alwaysEnabled: true, buttonTapped: {
            Current.navigate.close()
        }, type: .plain)
    }()
    
    var termsAndConditionsDescription: AttributedString {
        var attributedString = AttributedString(L10n.termsAndConditionsDescription)
        attributedString.font = .bodyTextLarge
        
        if let privacyPolicyRange = attributedString.range(of: L10n.privacyPolicy) {
            var container = AttributeContainer()
            container.link = URL(string: "https://bink.com/privacy-policy/")
            container.foregroundColor = .blueAccent
            container.underlineStyle = .single
            attributedString[privacyPolicyRange].mergeAttributes(container)
        }
        return attributedString
    }
}
