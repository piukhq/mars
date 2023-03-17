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
            Text(L10n.termsAndConditionsDescription)
                .uiFont(.bodyTextLarge)
                .padding(.horizontal, 25)
                .minimumScaleFactor(0.5)
            
            BinkButtonsStackView(buttons: [viewModel.iAcceptButton, viewModel.iDeclineButton])
//                .background(Color.pink)
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
            
        }, type: .gradient)
    }()
    
    lazy var iDeclineButton: BinkButtonSwiftUIView = {
        return BinkButtonSwiftUIView(viewModel: ButtonViewModel(title: L10n.iDecline), alwaysEnabled: true, buttonTapped: {
            
        }, type: .plain)
    }()
}
