//
//  ColorPallete.swift
//  binkapp
//
//  Created by Sean Williams on 11/11/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import Foundation

class ColorPallete {
    var primary = ""
    var secondary = ""
    
    var collection = [grecian, antique, warm, serene, lemonade, muted, watery, outdoorsy, primary, sleek, school]
    
    init() {
        configurePallete()
    }
    
    func configurePallete() {
        guard let randomPallete = collection.randomElement() else { return }
        var palleteSet = Set(randomPallete)
        primary = palleteSet.randomElement() ?? ""
        palleteSet.remove(primary)
        secondary = palleteSet.randomElement() ?? ""
    }
    
    static let grecian = ["#2f496e", "#ed8c72", "#2988bc", "#f4eade"]
    static let antique = ["#eab364", "#acbd78", "#a4cabc", "#b2473e"]
    static let warm = ["#ce5a57", "#e1b16a", "#444c5c", "#78a5a3"]
    static let serene = ["#ffdb5c", "#f8a055", "#4897db", "#fa6e59"]
    static let lemonade = ["#e2dfa2", "#ed5752", "#a1be95", "#92aac7"]
    static let muted = ["#002c54", "#cd7213", "#16253d", "#efb509"]
    static let watery = ["#004445", "#6fb98f", "#021c1e", "#2c7873"]
    static let outdoorsy = ["#486b00", "#7d4427", "#2e4600", "#a2c523"]
    static let primary = ["#fb6542", "#37681c", "#375e97", "#ffbb00"]
    static let sleek = ["#d5d6d2", "#3a5199", "#2f2e33", "#ffffff"]
    static let school = ["#fdc3c3", "#138d90", "#061283", "#ffb74c"]
}
