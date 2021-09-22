////
////  TermsAndConditionsViewController.swift
////  binkapp
////
////  Created by Max Woodhams on 03/11/2019.
////  Copyright © 2019 Bink. All rights reserved.
////
//
//import UIKit
//
//class TermsAndConditionsViewController: BaseFormViewController, UserServiceProtocol {
//    private lazy var continueButton: BinkButton = {
//        return BinkButton(type: .gradient, title: L10n.continueButtonTitle, enabled: false) { [weak self] in
////            self?.continueButtonTapped()
//        }
//    }()
//
//    private let requestType: LoginRequestType
//    
//    init(requestType: LoginRequestType) {
//        self.requestType = requestType
//        super.init(title: L10n.socialTandcsTitle, description: L10n.socialTandcsSubtitle, dataSource: FormDataSource(accessForm: .termsAndConditions))
//        dataSource.delegate = self
//    }
//    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        footerButtons = [continueButton]
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        setScreenName(trackedScreen: .socialTermsAndConditions)
//    }
//    
//    override func formValidityUpdated(fullFormIsValid: Bool) {
//        continueButton.enabled = fullFormIsValid
//    }
//    
////    @objc func continueButtonTapped() {
////        continueButton.toggleLoading(isLoading: true)
////
////        switch requestType {
////        case .apple(let request):
////            Current.loginController.loginWithApple(request: request, withPreferences: preferenceValues) { [weak self] error in
////                guard error == nil else {
////                    self?.handleAuthError()
////                    return
////                }
////            }
////        case .magicLink(let shortLivedToken):
////            Current.loginController.exchangeMagicLinkToken(token: shortLivedToken, withPreferences: preferenceValues) { error in
////                if let error = error {
////                    switch error {
////                    case .magicLinkExpired:
////                        Current.loginController.handleMagicLinkExpiredToken(token: "")
////                    default:
////                        Current.loginController.handleMagicLinkFailed(token: "")
////                    }
////                }
////            }
////        }
////    }
//    
////    private var preferenceValues: [String: String] {
////        var params: [String: String] = [:]
////
////        let preferences = dataSource.checkboxes.filter { $0.columnKind == .userPreference }
////        preferences.forEach {
////            if let columnName = $0.columnName {
////                params[columnName] = $0.value
////            }
////        }
////
////        return params
////    }
//    
////    private func showError() {
////        let message: String
////
////        switch requestType {
////        case .apple:
////            message = L10n.socialTandcsSiwaError
////        default:
////            message = L10n.loginError
////        }
////
////        let alert = BinkAlertController(title: L10n.errorTitle, message: message, preferredStyle: .alert)
////        alert.addAction(UIAlertAction(title: L10n.ok, style: .default))
////        present(alert, animated: true)
////    }
//
////    private func handleAuthError() {
////        Current.userManager.removeUser()
////        continueButton.toggleLoading(isLoading: false)
////        showError()
////    }
//    
//    override func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {
//        let viewController = ViewControllerFactory.makeWebViewController(urlString: URL.absoluteString)
//        let navigationRequest = ModalNavigationRequest(viewController: viewController)
//        Current.navigate.to(navigationRequest)
//    }
//}
//
//extension TermsAndConditionsViewController: FormDataSourceDelegate {
//    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
//        return true
//    }
//}
//
//extension TermsAndConditionsViewController: FormCollectionViewCellDelegate {
//    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {}
//    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
//}
