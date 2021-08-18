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
        ZStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text(field.title)
                        
                    TextField(field.placeholder, text: $value)
                }
                
                Image(systemName: "flag.circle")
            }
            Rectangle()
                .frame(width: 360, height: 20, alignment: .bottom)
                .offset(x: -30, y: 36)
        }
    }
}

struct BinkFormView_Previews: PreviewProvider {
    static var previews: some View {
        BinkFormView()
    }
}
