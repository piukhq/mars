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
    
    var collection = [grecian, antique]
    
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
}
