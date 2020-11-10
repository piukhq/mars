//
//  APIService.swift
//  binkapp
//
//  Created by Nick Farrant on 13/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

// swiftlint:disable type_name

import Foundation

/// Used when there isn't an object being passed into the completion handler, just a success bool where it makes sense not to complicate things with Result.
typealias ServiceCompletionSuccessHandler<ErrorType: BinkError> = (Bool, ErrorType?) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool.
typealias ServiceCompletionResultHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>) -> Void

/// Used when we need to pass an object or set of objects through the completion handler rather than just a success bool, and the completion handler requires context of the raw http response.
typealias ServiceCompletionResultRawResponseHandler<ObjectType: Any, ErrorType: BinkError> = (Result<ObjectType, ErrorType>, HTTPURLResponse?) -> Void
