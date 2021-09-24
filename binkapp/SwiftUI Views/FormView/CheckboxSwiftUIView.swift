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
    @State var checked = false
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack {
                Button(action: {
                    checked.toggle()
                }, label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(checked ? Color.black : Color.gray.opacity(0.4))
                            .frame(width: 22, height: 22)
                        
                        if checked {
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
//            .background(Color(.purple))

            
            Text(checkboxText)
                .foregroundColor(Color(Current.themeManager.color(for: .text)))
                .font(.nunitoLight(14))
//                .background(Color(.green))
            Spacer()
        }
        .padding()
//        .background(Color(.systemPink))
    }
}
struct CheckboxSwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        CheckboxSwiftUIView(checkboxText: "Check this box to receive money off promotion, special offers and information on latest deals and more from Iceland by email")
    }
}
