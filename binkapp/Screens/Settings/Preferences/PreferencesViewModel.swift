//
//  PreferencesViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 20/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

protocol PreferencesDelegate: class {
    func didReceivePreferences()
}

class PreferencesViewModel {
    private let repository: PreferencesRepository
    private let router: MainScreenRouter
    
    weak var delegate: PreferencesDelegate?
    
    var preferences: [PreferencesModel] = [] {
        didSet {
            delegate?.didReceivePreferences()
        }
    }
    
    init(repository: PreferencesRepository, router: MainScreenRouter) {
        self.repository = repository
        self.router = router
    }
    
    func getPreferences(completion: @escaping ([PreferencesModel]) -> Void) {
        repository.getPreferences(onSuccess: { (preferences) in
            self.preferences = preferences
            completion(preferences)
        }) { (error) in
            self.router.displaySimplePopup(title: nil, message: error.localizedDescription)
        }
    }
    
    func putPreferences(preferences: [String: String], onSuccess: @escaping () -> Void, onError: @escaping (Error) -> Void) {
        repository.putPreferences(preferences: preferences, onSuccess: {
            onSuccess()
        }) { (error) in
            onError(error)
        }
    }
}
