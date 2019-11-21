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
    
    var preferences: [PreferencesModel] = []
    
    init(repository: PreferencesRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getPreferences() {
        repository.getPreferences(onSuccess: { (preferences) in
            self.preferences = preferences
        }) { (error) in
            self.router.displaySimplePopup(title: nil, message: error.localizedDescription)
        }
    }
    
    func popViewController() {
        router.popViewController()
    }
}
