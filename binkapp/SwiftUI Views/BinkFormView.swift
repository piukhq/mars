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
    
//    init(datasource: FormDataSource) {
//        self.datasource = datasource
//    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            ForEach(datasource.fields) { field in
                BinkCell(field: field)
                    .environmentObject(datasource)
//                Spacer(minLength: 20)
            }
        }
        .background(Color(UIColor.binkWhiteViewBackground))
        
//        .environmentObject(datasource)
    }
}

struct BinkCell: View {
    var field: FormField
    
    @State private var isEditing = false
    @State var value: String = ""
    
    
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(field.title)
                        .font(.custom(UIFont.bodyTextSmall.fontName, size: UIFont.bodyTextSmall.pointSize))
                    
                    TextField(field.placeholder, text: $value) { isEditing in
                        self.isEditing = isEditing
                    } onCommit: {
                        print("Did commit: \(value)")
                    }
                    .font(.custom(UIFont.textFieldInput.fontName, size: UIFont.textFieldInput.pointSize))
                }
                Image(systemName: "flag.circle")
            }
            .padding()
            
            Rectangle()
                .fill(Color(isEditing ? .activeBlue : .clear))
                .frame(minWidth: 0, maxWidth: .infinity, maxHeight: 6, alignment: .top)
                .clipped()
                .offset(y: 39)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .background(Color(UIColor.binkWhiteViewBackground))
        .frame(width: nil, height: 80, alignment: .center)
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
