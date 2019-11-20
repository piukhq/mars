//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

class PreferencesViewModel {
    private let repository: PreferencesRepository
    private let router: MainScreenRouter
    
    init(repository: PreferencesRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func popViewController() {
        router.popViewController()
    }
}
