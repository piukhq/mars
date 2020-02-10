//
//  PendingViewModel.swift
//  binkapp
//
//  Created by Paul Tiriteu on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation

enum PendingType {
    case login
    case signup
    case register
}

class SimpleInfoViewModel {
    private let router: MainScreenRouter
    private let pendingType: PendingType
    
    var title: String {
        switch pendingType {
            case .login:
                return "log_in_pending_title".localized
            case .signup:
                return "sign_up_pending_title".localized
            case .register:
                return "register_pending_title".localized
        }
    }
    
    var description: String {
        switch pendingType {
        case .login:
            return "log_in_pending_description".localized
        case .signup:
            return "sign_up_pending_description".localized
        case .register:
            return "register_pending_description".localized
        }
    }
    
    init(router: MainScreenRouter, pendingType: PendingType) {
        self.router = router
        self.pendingType = pendingType
    }
    
    func popViewController() {
        router.popViewController()
    }
}
