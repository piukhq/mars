//
//  CheckboxSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 05/08/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import SwiftUI

struct CheckboxSwiftUIView: View {
    @ObservedObject var viewModel: CheckboxViewModel
    var checkboxSelected: () -> Void
    var didTapOnURL: ((URL) -> Void)?

    var body: some View {
        Button(action: {
            viewModel.checkedState.toggle()
            checkboxSelected()
        }, label: {
            HStack(alignment: .center, spacing: 10) {
                if !viewModel.hideCheckbox {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(viewModel.checkedState ? Color.black : Color((.systemGray.lighter() ?? .systemGray)))
                            .frame(width: 22, height: 22)
                        
                        if viewModel.checkedState {
                            Image(Asset.checkmark.name)
                                .resizable()
                                .frame(width: 15, height: 15, alignment: .center)
                                .foregroundColor(.white)
                        } else {
                            RoundedRectangle(cornerRadius: 2.7, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 18, height: 18)
                        }
                    }
                }
                
                Text(viewModel.attributedText ?? AttributedString(viewModel.checkboxText))
                    .uiFont(.bodyTextSmall)
                    .foregroundColor(Color(Current.themeManager.color(for: .text)))
                    .multilineTextAlignment(.leading)
                    .environment(\.openURL, OpenURLAction { url in
                        print(url)
                        didTapOnURL?(url)
                        return .handled
                    })
                Spacer()
            }
        })
        .background(Color(Current.themeManager.color(for: .viewBackground)))
    }
}

//struct CheckboxSwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            let viewModel = CheckboxViewModel(checkedState: true, text: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email", columnName: nil, columnKind: .planDocument, url: URL(string: ""), optional: false, hideCheckbox: false)
//            CheckboxSwiftUIView(viewModel: viewModel, checkboxSelected: {})
//            let viewModel2 = CheckboxViewModel(checkedState: false, text: "I accept the Retailer terms and conditions", columnName: "Retailer terms and conditions", columnKind: .planDocument, url: URL(string: "www.apple.com"), optional: false, hideCheckbox: false)
//            CheckboxSwiftUIView(viewModel: viewModel2, checkboxSelected: {})
//        }
//    }
//}
