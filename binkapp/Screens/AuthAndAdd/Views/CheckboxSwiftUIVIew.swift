//
//  CheckboxSwiftUIVIew.swift
//  binkapp
//
//  Created by Sean Williams on 06/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI
import UIKit

struct CheckboxSwiftUIVIew: UIViewRepresentable {
    var checkbox: CheckboxView
    @Binding var checkedState: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(checkedState: $checkedState)
    }
    
    func makeUIView(context: Context) -> CheckboxView {
        checkbox.delegate = context.coordinator
        return checkbox
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.checkedState = checkedState
    }
}

extension CheckboxSwiftUIVIew {
    class Coordinator: NSObject, CheckboxViewDelegate {
        @Binding private var checkedState: Bool
        
        init(checkedState: Binding<Bool>) {
            _checkedState = checkedState
        }
        
        func checkboxView(_ checkboxView: CheckboxView, didCompleteWithColumn column: String, value: String, fieldType: FormField.ColumnKind) {
            checkedState = checkboxView.checkedState
        }
    }
}
