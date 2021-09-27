//
//  CheckboxSwiftUIView.swift
//  binkapp
//
//  Created by Sean Williams on 24/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

struct CheckboxSwiftUIView: View {
    @State var checkboxText = ""
    @State var checkedState = false
    var hideCheckbox = false
    var columnKind: FormField.ColumnKind?
    var optional = false
    var columnName: String?
    var url: URL?
    var value: String {
        return checkedState ? "1" : "0"
    }
    
    init (text: String, columnName: String?, columnKind: FormField.ColumnKind, url: URL? = nil, optional: Bool = false, hideCheckbox: Bool = false) {
        self._checkboxText = State(initialValue: text)
        self.columnName = columnName
        self.columnKind = columnKind
        self.url = url
        self.optional = optional
        self.hideCheckbox = hideCheckbox
    }

    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack {
                Button(action: {
                    checkedState.toggle()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(checkedState ? Color.black : Color.gray.opacity(0.4))
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
            
            Text(checkboxText)
                .foregroundColor(Color(Current.themeManager.color(for: .text)))
                .font(.nunitoLight(14))
            Spacer()
        }
    }
}
//struct CheckboxSwiftUIView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckboxSwiftUIView(checkboxText: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email")
//    }
//}
