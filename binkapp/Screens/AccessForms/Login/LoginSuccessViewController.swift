//
//  LoginSuccessViewController.swift
//  binkapp
//
//  Created by Sean Williams on 20/07/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import Lottie
import UIKit

class LoginSuccessViewController: BaseFormViewController, UserServiceProtocol {
    enum Constants {
        static let animationDimension: CGFloat = 300
    }
    
    private lazy var continueButton: BinkButton = {
        return BinkButton(type: .capsule, title: L10n.continueButtonTitle) { [weak self] in
            self?.continueButtonTapped()
        }
    }()
 
    private lazy var animationView: AnimationView = {
        let animationView = AnimationView(name: "success")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        animationView.widthAnchor.constraint(equalToConstant: Constants.animationDimension).isActive = true
        return animationView
    }()
    
    init() {
        let emailAddress = Current.userManager.currentEmailAddress
        let attributedBody = NSMutableAttributedString(string: L10n.loginSuccesSubtitle(emailAddress ?? L10n.nilEmailAddress), attributes: [.font: UIFont.bodyTextLarge])
        let baseBody = NSString(string: attributedBody.string)
        let emailRange = baseBody.range(of: emailAddress ?? "")
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "NunitoSans-ExtraBold", size: 18.0) ?? UIFont()]
        attributedBody.addAttributes(attributes, range: emailRange)
        
        super.init(title: L10n.loginSuccessTitle, description: "", attributedDescription: attributedBody, dataSource: FormDataSource(accessForm: .success))
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        footerButtons = [continueButton]
        stackScrollView.insert(arrangedSubview: animationView, atIndex: 0)
        stackScrollView.alignment = .center
        textView.textAlignment = .center
        animationView.play()
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        titleLabel.textColor = .binkBlue
    }
    
    @objc func continueButtonTapped() {
        continueButton.toggleLoading(isLoading: true)
        
        let preferenceCheckbox = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
        var params: [String: String] = [:]
        
        preferenceCheckbox.forEach {
            if let columnName = $0.columnName {
                params[columnName] = $0.value
            }
        }
        
        guard !params.isEmpty else {
            Current.navigate.close()
            return
        }
        setPreferences(params: params)
        Current.navigate.close()
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
