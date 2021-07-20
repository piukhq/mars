//
//  LoginSuccessViewController.swift
//  binkapp
//
//  Created by Sean Williams on 20/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class LoginSuccessViewController: BaseFormViewController {
    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .gradient, title: L10n.continueButtonTitle) { [weak self] in
            self?.continueButtonTapped()
        }
    }()
    
    init() {
        super.init(title: "SUCCESS", description: L10n.socialTandcsSubtitle, dataSource: FormDataSource(accessForm: .success))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        footerButtons = [continueButton]
    }
    
    @objc func continueButtonTapped() {
        continueButton.toggleLoading(isLoading: true)
        
        Current.rootStateMachine.handleLogin() // << move to success screen continue tap

//        if let preferences = preferences {
//            self?.setPreferences(params: preferences) // << move to success screen continue tap
//        }
    }
}


extension LoginSuccessViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
}

extension LoginSuccessViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}
