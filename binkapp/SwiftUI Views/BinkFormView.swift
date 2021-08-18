//
//  BinkFormView.swift
//  binkapp
//
//  Created by Sean Williams on 17/08/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

let shouldChangeBlock: FormField.TextFieldShouldChange = { (_, _, _, _) in
    return false
}

let field1 = FormField(title: "Email", placeholder: "Enter your email bitch", validation: "", fieldType: .email, updated: { _, _ in }, shouldChange: shouldChangeBlock, fieldExited: { _ in })

struct BinkFormView: View {
    private let datasource: [FormField] = [field1]
    
    var body: some View {
        Form {
            ForEach(datasource) { field in
                BinkFormTextfield(field: field)
            }
        }
    }
}

struct BinkFormTextfield: View {
    @State var value: String = ""
    var field: FormField
    
    var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(field.title)
                        .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                    
                    TextField(field.placeholder, text: $value)
                        .padding(.bottom, 8.0)
                        .font(.custom(UIFont.textFieldInput.fontName, size: UIFont.textFieldInput.pointSize))
                }
                
                Image(systemName: "flag.circle")
            }
            .offset(x: -6.0)
            .background(
                Rectangle()
                    .frame(width: 350, height: 20, alignment: .bottom)
                    .offset(x: 0, y: 41))
    }
}

struct BinkFormView_Previews: PreviewProvider {
    static var previews: some View {
        BinkFormView()
    }
}
