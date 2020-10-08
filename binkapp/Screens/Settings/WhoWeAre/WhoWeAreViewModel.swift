//
//  WhoWeAreViewModel.swift
//  binkapp
//
//  Created by Sean Williams on 07/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import Foundation

class WhoWeAreViewModel {
    
    var teamMembers: [String] {
        return BinkTeam.members
    }
}

struct BinkTeam {
    static let members = [
        "Paul Batty",
        "Nick Farrant",
        "Susanne King",
        "Srikalyani Kotha",
        "Marius Lobontiu",
        "Carmen Muntean",
        "Dorin Pop",
        "Karl Sigiscar",
        "Paul Tiritieu",
        "Sean Williams",
        "Max Woodhams"
    ]
}
