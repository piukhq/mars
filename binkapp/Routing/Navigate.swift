//
//  Navigate.swift
//  binkapp
//
//  Created by Nick Farrant on 14/08/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

enum NavigationTransition {
    case push
    case modal
}

protocol Navigate {
    func navigate(to destination: UIViewController, withTransition transition: NavigationTransition)
}

extension Navigate where Self: UIViewController {
    func navigate(to destination: UIViewController, withTransition transition: NavigationTransition) {
        switch transition {
        case .push:
            navigationController?.pushViewController(destination, animated: true)
        case .modal:
            present(destination, animated: true, completion: nil)
        }
    }
}

protocol Router: Navigate {}

extension Router where Self: SettingsViewController {
    func toPreferences() {
        // repositories dont need api client injection
        // view models don't need router injection
        let viewController = PreferencesViewController(viewModel: PreferencesViewModel(repository: PreferencesRepository(apiClient: Current.apiClient), router: MainScreenRouter(delegate: nil)))
        navigate(to: viewController, withTransition: .push)
    }
}

extension Router where Self: BrowseBrandsViewController {
    func toSomethingElse() {
        
    }
}
