//
//  CustomError.swift
//  binkapp
//
//  Created by Paul Tiriteu on 15/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

class CustomError: LocalizedError {
    private let error: Error
    
    init(_ error: Error) {
        self.error = error
    }
    
    var localizedDescription: String {
        guard let errorDescription = errorDescription else {
            return ""
        }
        return errorDescription
    }
}
