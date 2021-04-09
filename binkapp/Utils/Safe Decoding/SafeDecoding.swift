//
//  SafeDecoding.swift
//  binkapp
//
//  Created by Nick Farrant on 07/04/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Foundation

struct Safe<Base: Decodable>: Decodable {
    let value: Base?

    init(from decoder: Decoder) throws {
        do {
            let container = try decoder.singleValueContainer()
            self.value = try container.decode(Base.self)
        } catch {
            self.value = nil
        }
    }
}
