//
//  String+Random.swift
//  binkapp
//
//  Created by Max Woodhams on 19/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

extension String {
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in
            return letters.randomElement()!
        })
    }
}
