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
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var optional = false
    private(set) var columnName: String?
    var value: String {
        return checkedState ? "1" : "0"
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
//        .padding()
    }
}
struct CheckboxSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxSwiftUIView(checkboxText: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email")
    }
}
