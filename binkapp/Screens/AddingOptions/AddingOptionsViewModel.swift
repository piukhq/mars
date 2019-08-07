//
//  AddingOptionsViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 06/08/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class AddingOptionsViewModel {
    let router: MainScreenRouter
    
    init(router: MainScreenRouter) {
        self.router = router
    }
    
    func popViewController() {
        router.popViewController()
    }
}
