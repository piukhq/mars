//
//  CustomError.swift
//  binkapp
//
//  Created by Paul Tiriteu on 15/01/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

// TODO: Remove this. Only used in old APIManager and add auth, handle this case with modular error
class CustomError: Error {
    private let errorMessage: String
    private let statusCode: Int
    
    init(errorMessage: String, statusCode: Int) {
        self.errorMessage = errorMessage
        self.statusCode = statusCode
    }
    
    var localizedDescription: String {
        return errorMessage
    }
}
