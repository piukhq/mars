//
//  SocialTermsAndConditionsViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SocialTermsAndConditionsViewController: BaseFormViewController {
    private lazy var continueButton: BinkGradientButton = {
        let button = BinkGradientButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.buttonText
        button.addTarget(self, action: .continueButtonTapped, for: .touchUpInside)
        button.isEnabled = false
        view.addSubview(button)
        return button
    }()
    
    private let router: MainScreenRouter?
    private var request: FacebookRequest? // Variable so we can nil this object
        
    init(router: MainScreenRouter?, request: FacebookRequest) {
        self.router = router
        self.request = request
        super.init(title: "Terms and conditions", description: "One last step...", dataSource: FormDataSource(accessForm: .socialTermsAndConditions))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        NSLayoutConstraint.activate([
            continueButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: LayoutHelper.PillButton.widthPercentage),
            continueButton.heightAnchor.constraint(equalToConstant: LayoutHelper.PillButton.height),
            continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -LayoutHelper.PillButton.bottomPadding),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {                        
        let api = ApiManager()
        
        api.doRequest(url: .facebook, httpMethod: .post, parameters: request, onSuccess: { [weak self] (response: LoginRegisterResponse) in
            Current.userManager.setNewUser(with: response)
            self?.router?.didLogin()
            self?.request = nil
        }) { (error) in
            print(error)
        }
    }
}

extension SocialTermsAndConditionsViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
}

private extension Selector {
    static let continueButtonTapped = #selector(SocialTermsAndConditionsViewController.continueButtonTapped)
}
