//
//  SafeDecoding.swift
//  binkapp
//
//  Created by Nick Farrant on 07/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

public struct Safe<Base: Decodable>: Decodable {
    public let value: Base?

    public init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
//            assertionFailure("ERROR: \(error)")
            // TODO: automatically send a report about a corrupted data
            self.value = nil
        }
    }
}
