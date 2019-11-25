//
//  SocialTermsAndConditionsViewController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SocialTermsAndConditionsViewController: BaseFormViewController {
    private let api = ApiManager()

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
    
    private lazy var message: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.attributedText = messageString
        return label
    }()
    
    private lazy var messageString: NSAttributedString = {
        let attrString = NSMutableAttributedString(string: "Make sure you’re the first to know about available rewards, offers and updates!\nYou can opt out at any time.", attributes: [.font : UIFont.bodyTextLarge])
        let base: NSString = NSString(string: attrString.string)
        let rewardsRange = base.range(of: "rewards")
        let offersRange = base.range(of: "offers")
        let updatesRange = base.range(of: "updates")
        
        let attributes: [NSAttributedString.Key : Any]  = [.font : UIFont.subtitle]
        
        attrString.addAttributes(attributes, range: rewardsRange)
        attrString.addAttributes(attributes, range: offersRange)
        attrString.addAttributes(attributes, range: updatesRange)
        
        return attrString
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
        let lastView = stackScrollView.arrangedSubviews.last
        stackScrollView.add(arrangedSubview: message)
        
        if let lastView = lastView {
            stackScrollView.customPadding(18.0, after: lastView)
        }
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        continueButton.isEnabled = fullFormIsValid
    }
    
    @objc func continueButtonTapped() {
        let preferenceCheckboxes = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
        
        continueButton.startLoading()
        
        api.doRequest(url: .facebook, httpMethod: .post, parameters: request, onSuccess: { [weak self] (response: LoginRegisterResponse) in
            Current.userManager.setNewUser(with: response)
            self?.router?.didLogin()
            self?.updatePreferences(checkboxes: preferenceCheckboxes)
            self?.request = nil
            self?.continueButton.stopLoading()
        }) { [weak self] (error) in
            self?.continueButton.stopLoading()
        }
    }
    
    func updatePreferences(checkboxes: [CheckboxView]) {
         
         var params = [String: Any]()
         
         checkboxes.forEach {
             if let columnName = $0.columnName {
                 params[columnName] = $0.jsonValue
             }
         }
         
         guard params.count > 0 else { return }
         
         // We don't worry about whether this was successful or not
         api.doRequestWithNoResponse(url: .preferences, httpMethod: .put, parameters: params, completion: nil)
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
