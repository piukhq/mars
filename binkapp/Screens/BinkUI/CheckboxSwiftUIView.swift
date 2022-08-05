//
//  CheckboxSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 24/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct CheckboxSwiftUIView: View {
    typealias CheckValidity = () -> Void

    @State var checkboxText: String
    @State var checkedState = false

    var attributedText: AttributedString?
    var hideCheckbox: Bool
    var columnKind: FormField.ColumnKind
    var optional: Bool
    var columnName: String?
    var url: URL?
    var checkValidity: CheckValidity
    
    var value: String {
        return checkedState ? "1" : "0"
    }
    
//    var isValid: Bool {
//        if hideCheckbox {
//            return true
//        }
//        return optional ? true : viewModel.checkedState
//    }
    
    init (checkedState: Bool, text: String? = nil, attributedText: AttributedString? = nil, columnName: String?, columnKind: FormField.ColumnKind, url: URL? = nil, optional: Bool = false, hideCheckbox: Bool = false, checkValidity: @escaping CheckValidity) {
        _checkedState = State(initialValue: checkedState)
        self._checkboxText = State(initialValue: text ?? "")
        self.columnName = columnName
        self.columnKind = columnKind
        self.url = url
        self.optional = optional
        self.hideCheckbox = hideCheckbox
        self.checkValidity = checkValidity
        
        guard let safeUrl = url, let attributedText = attributedText, let columnName = columnName else {
            self.attributedText = attributedText
            return
        }
        
        var string = attributedText
        string.font = .custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize)

        if let urlRange = string.range(of: columnName) {
            var container = AttributeContainer()
            container.link = safeUrl
            container.foregroundColor = Color(UIColor.blueAccent)
            container.underlineStyle = .single
            string[urlRange].mergeAttributes(container)
            self.attributedText = string
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            if !hideCheckbox {
                VStack {
                    Button(action: {
                        checkedState.toggle()
                        checkValidity()
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(checkedState ? Color.black : Color((.systemGray.lighter() ?? .systemGray)))
                                .frame(width: 22, height: 22)
                            
                            if checkedState {
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
                    })
                }
            }
            Text(attributedText ?? AttributedString(checkboxText))
                .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
//            TextWithAttributedString(attributedText: attributedText ?? NSAttributedString(string: checkboxText), url: $viewModel.url)
            Spacer()
        }
        .padding(.bottom, columnName == L10n.tandcsLink ? 20 : 0)
    }
}

struct CheckboxSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CheckboxSwiftUIView(checkedState: true, text: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email", columnName: nil, columnKind: .planDocument, url: URL(string: ""), optional: false, hideCheckbox: false, checkValidity: {})
            CheckboxSwiftUIView(checkedState: false, text: "I accept the Retailer terms and conditions", columnName: "Retailer terms and conditions", columnKind: .planDocument, url: URL(string: "www.apple.com"), optional: false, hideCheckbox: false, checkValidity: {})
            CheckboxSwiftUIView(checkedState: true, text: "I accept the Iceland privacy policy", columnName: "Iceland privacy policy", columnKind: .planDocument, url: URL(string: "www.apple.com"), optional: false, hideCheckbox: false, checkValidity: {})
        }
    }
}
