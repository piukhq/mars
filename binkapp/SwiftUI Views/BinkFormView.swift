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
let datasourceMock = FormDataSource(accessForm: .emailPassword)


struct BinkFormView: View {
    @EnvironmentObject var datasource: FormDataSource
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(datasource.fields) { field in
                BinkCell(field: field)
                    .environmentObject(datasource)
            }
        }
        .background(Color(UIColor.binkWhiteViewBackground))
    }
}

struct BinkCell: View {
    @State var field: FormField
    @State private var isEditing = false
    @State var value: String = ""
    
    init(field: FormField) {
        self.field = field
        UITextField.appearance().clearButtonMode = field.fieldCommonName == .barcode ? .always : .whileEditing
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .foregroundColor(.white)
                
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(field.title)
                            .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                        
                        if field.fieldType.isSecureTextEntry {
                            SecureField(field.placeholder, text: $value) {
                                self.field.updateValue(value)
                                self.field.fieldWasExited()
                                self.isEditing = false
                            }
                            .onTapGesture {
                                isEditing = true
                            }
                        } else {
                            TextField(field.placeholder, text: $value, onEditingChanged: { isEditing in
                                self.isEditing = isEditing
                                self.field.updateValue(value)
                                self.field.fieldWasExited()
                            }, onCommit: {
                                print("Did commit: \(value)")
                            })
                            .font(.custom(UIFont.textFieldInput.fontName, size: UIFont.textFieldInput.pointSize))
                            .autocapitalization(field.fieldType.capitalization())
    //                        .accessibilityIdentifier(field.title)
                        }
                    }
                    
                    if field.isValid() && !isEditing {
                        Image(systemName: "flag.circle")
                            .offset(x: -5, y: 11)
                    }
                }
                .padding([.leading, .trailing], 15)
                
                Rectangle()
                    .fill(underlineColor(isEdting: $isEditing))
//                    .fill(Color(.activeBlue))
                    .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 6, alignment: .top)
                    .clipped()
                    .offset(y: 34)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(Color(UIColor.binkWhiteViewBackground))
            .frame(width: nil, height: 70, alignment: .center)
            
            if field.fieldType.isSecureTextEntry {
                // TODO: - Validation point Texts
            } else {
                if !field.isValid() && !value.isEmpty && !isEditing {
                    Text(field.validationErrorMessage ?? L10n.formFieldValidationError)
                        .font(.custom(UIFont.textFieldExplainer.fontName, size: UIFont.textFieldExplainer.pointSize))
                        .foregroundColor(Color(.errorRed))
                }
            }
        }
    }
    
    private func underlineColor(isEdting: Binding<Bool>) -> Color {
        var color: UIColor
        
        if isEditing {
            color = .activeBlue
        } else {
            color = field.isValid() ? .successGreen : .errorRed
        }
        
        if value.isEmpty && !isEditing {
            color = .clear
        }
        return Color(color)
    }
}

//struct BinkTextFieldView: View {
//    @State var value: String = ""
//    var field: FormField
//
//    var body: some View {
//        HStack {
//            VStack(alignment: .leading, spacing: 0) {
//                Text(field.title)
//                    .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
//
//                TextField(field.placeholder, text: $value) { isEditing in
//
//                } onCommit: {
//
//                }
//                .font(.custom(UIFont.textFieldInput.fontName, size: UIFont.textFieldInput.pointSize))
//            }
//            Image(systemName: "flag.circle")
//        }
//    }
//}

struct BinkFormTextfield: View {
    @State var value: String = ""
    var field: FormField
    
    var body: some View {
//        ZStack {
//        RoundedRectangle(cornerRadius: 25.0, style: .continuous)
//            .fill(Color.white)
//            .frame(width: nil, height: 80, alignment: .center)
//            .background(
//                   Rectangle()
//                       .fill(Color(UIColor.activeBlue))
////                       .frame(width: 490, height: 20, alignment: .bottom)
////                       .offset(x: -20, y: 0))
//        )
//            .overlay(
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
        .cornerRadius(20)
        .padding()
//        )
//        .background(RoundedRectangle(cornerRadius: 15)
//                        .fill(Color.white))
        .background(
               Rectangle()
                   .fill(Color(UIColor.activeBlue))
                   .frame(width: 490, height: 20, alignment: .bottom)
                   .offset(x: -20, y: 50))

        .offset(x: -6.0)
        }
    }
//}

struct BinkFormView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(UIColor.grey10))
                BinkFormView()
                    .environmentObject(datasourceMock)
                    .preferredColorScheme(.light)
            }
        }
    }
}
