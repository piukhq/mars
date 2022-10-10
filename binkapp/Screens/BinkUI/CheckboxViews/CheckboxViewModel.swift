//
//  CheckboxSwiftUIViewViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 28/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

class CheckboxViewModel: ObservableObject, Identifiable {
    @Published var checkboxText: String
    @Published var checkedState = false
    @Published var textColour = Current.themeManager.color(for: .text)

    private(set) var attributedText: AttributedString?
    private(set) var hideCheckbox: Bool
    private(set) var columnKind: FormField.ColumnKind?
    private(set) var optional: Bool
    private(set) var columnName: String?
    private(set) var url: URL?

    init (checkedState: Bool, text: String? = nil, attributedText: AttributedString? = nil, columnName: String?, columnKind: FormField.ColumnKind?, url: URL? = nil, optional: Bool = false, hideCheckbox: Bool = false) {
        self.checkedState = checkedState
        self.checkboxText = text ?? ""
        self.columnName = columnName
        self.columnKind = columnKind
        self.url = url
        self.optional = optional
        self.hideCheckbox = hideCheckbox
        
        Current.themeManager.addObserver(self, handler: #selector(configureForCurrentTheme))
        
        guard let safeUrl = url, let attributedText = attributedText, let columnName = columnName else {
            self.attributedText = attributedText
            return
        }
        
        var string = attributedText
        string.font = .bodyTextSmall

        if let urlRange = string.range(of: columnName) {
            var container = AttributeContainer()
            container.link = safeUrl
            container.foregroundColor = Color(UIColor.blueAccent)
            container.underlineStyle = .single
            string[urlRange].mergeAttributes(container)
            self.attributedText = string
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    var value: String {
        return checkedState ? "1" : "0"
    }
    
    /// Should only be used when the API call triggered by the delegate method fails, and we need to revert the state
    func reset() {
        checkedState.toggle()
    }
    
    @objc private func configureForCurrentTheme() {
        textColour = Current.themeManager.color(for: .text)
    }
}

extension CheckboxViewModel: InputValidation {
    var isValid: Bool {
        if hideCheckbox {
            return true
        }
        return optional ? true : checkedState
    }
}
