//
//  Binding+Extension.swift
//  binkapp
//
//  Created by Sean Williams on 13/09/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SwiftUI

extension Binding {
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
    
    static func ?? (lhs: Binding<Optional<Value>>, rhs: Value) -> Binding<Value> {
        Binding(get: { lhs.wrappedValue ?? rhs }, set: { lhs.wrappedValue = $0 })
    }
}
