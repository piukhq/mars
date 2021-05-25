//
//  AuthAndAddViewModel.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import UIKit

enum FieldType {
    case add
    case authorise
    case enrol
}

enum InputType: Int {
    case textfield = 0
    case sensitive
    case dropdown
    case checkbox
}

enum FormPurpose: Equatable {
    case add
    case addFailed
    case addFromScanner
    case signUp
    case signUpFailed
    case ghostCard
    case patchGhostCard
    
    var planDocumentDisplayMatching: PlanDocumentDisplayModel {
        switch self {
        case .add, .addFailed, .addFromScanner:
            return .add
        case .signUp, .signUpFailed:
            return .enrol
        case .ghostCard, .patchGhostCard:
            return .registration
        }
    }
}

class AuthAndAddViewModel {
    private let repository = AuthAndAddRepository()
    private let membershipPlan: CD_MembershipPlan
    let prefilledFormValues: [FormDataSource.PrefilledValue]?
    
    private var fieldsViews: [InputValidation] = []
    private var membershipCardPostModel: MembershipCardPostModel?
    private var existingMembershipCard: CD_MembershipCard?
    
    var formPurpose: FormPurpose
    
    var title: String {
        switch formPurpose {
        case .signUp, .signUpFailed: return L10n.signUpNewCardTitle(membershipPlan.account?.planName ?? "a new card")
        case .add, .addFromScanner: return L10n.credentialsTitle
        case .addFailed: return L10n.logInTitle
        case .ghostCard, .patchGhostCard: return L10n.registerGhostCardTitle
        }
    }
    
    var buttonTitle: String {
        switch formPurpose {
        case .signUp: return L10n.signUpButtonTitle
        case .add, .addFromScanner: return L10n.pllScreenAddTitle
        case .ghostCard: return L10n.registerCardTitle
        case .signUpFailed, .addFailed, .patchGhostCard: return L10n.logInTitle
        }
    }
    
    var accountButtonShouldHide: Bool {
        return formPurpose != .add || formPurpose == .ghostCard
    }
    
    init(membershipPlan: CD_MembershipPlan, formPurpose: FormPurpose, existingMembershipCard: CD_MembershipCard? = nil, prefilledFormValues: [FormDataSource.PrefilledValue]? = nil) {
        self.membershipPlan = membershipPlan
        self.membershipCardPostModel = MembershipCardPostModel(account: AccountPostModel(), membershipPlan: Int(membershipPlan.id))
        self.existingMembershipCard = existingMembershipCard
        self.formPurpose = formPurpose
        self.prefilledFormValues = prefilledFormValues
    }
    
    func getDescription() -> String? {
        switch formPurpose {
        case .add, .addFromScanner:
            guard let companyName = membershipPlan.account?.companyName else { return nil }
            return L10n.authScreenDescription(companyName)
        case .signUp:
            if let planSummary = membershipPlan.account?.planSummary {
                return planSummary
            } else if let planNameCard = membershipPlan.account?.planNameCard {
                return L10n.signUpNewCardDescription(planNameCard)
            }
            return nil
        case .ghostCard, .patchGhostCard:
            if membershipPlan.isPLL, let description = membershipPlan.account?.planRegisterInfo {
                return description
            }
            guard let planNameCard = membershipPlan.account?.planNameCard else { return nil }
            return L10n.registerGhostCardDescription(planNameCard)
        case .addFailed, .signUpFailed:
            return getDescriptionForOtherLogin()
        }
    }
    
    var shouldRemoveScannerFromStack: Bool {
        return formPurpose == .addFromScanner
    }
    
    private func getDescriptionForOtherLogin() -> String {
        guard let planNameCard = membershipPlan.account?.planNameCard else { return "" }
        
        if hasPoints() {
            guard let transactionsAvailable = membershipPlan.featureSet?.transactionsAvailable else {
                return L10n.onlyPointsLogInDescription(planNameCard)
            }
            return transactionsAvailable.boolValue ? L10n.pointsAndTransactionsLogInDescription(planNameCard) : L10n.onlyPointsLogInDescription(planNameCard)
        } else {
            return ""
        }
    }
    
    private func hasPoints() -> Bool {
        guard let hasPoints = membershipPlan.featureSet?.hasPoints else { return false }
        return hasPoints.boolValue
    }
    
    func getMembershipPlan() -> CD_MembershipPlan {
        return membershipPlan
    }

    func addMembershipCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil, completion: @escaping () -> Void) throws {
        guard formPurpose != .ghostCard, formPurpose != .patchGhostCard else {
            try addGhostCard(with: formFields, checkboxes: checkboxes, existingMembershipCard: existingMembershipCard)
            return
        }
        
        formFields.forEach { addFieldToCard(formField: $0) }
        checkboxes?.forEach { addCheckboxToCard(checkbox: $0) }
        
        guard let model = membershipCardPostModel else { return }
        
        guard model.account?.hasValidPayload == true else {
            displaySimplePopup(title: L10n.errorTitle, message: L10n.addLoyaltyCardErrorMessage)
            completion()
            return
        }
        
        BinkAnalytics.track(CardAccountAnalyticsEvent.addLoyaltyCardRequest(request: model, formPurpose: formPurpose))
        let scrapingCredentials = Current.pointsScrapingManager.makeCredentials(fromFormFields: formFields, membershipPlanId: membershipPlan.id)
        
        repository.addMembershipCard(request: model, formPurpose: formPurpose, existingMembershipCard: existingMembershipCard, scrapingCredentials: scrapingCredentials, onSuccess: { card in
            if let card = card {
                // Navigate to LCD for the new card behind the modal
                let lcdViewController = ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: card)
                let lcdNavigationRequest = PushNavigationRequest(viewController: lcdViewController)
                let tabNavigationRequest = TabBarNavigationRequest(tab: .loyalty, popToRoot: true, backgroundPushNavigationRequest: lcdNavigationRequest) {
                    if card.membershipPlan?.isPLL == true {
                        PllLoyaltyInAppReviewableJourney().begin()

                        let viewController = ViewControllerFactory.makePllViewController(membershipCard: card, journey: .newCard)
                        let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
                        Current.navigate.to(navigationRequest)
                    } else {
                        Current.navigate.close()
                    }
                    completion()
                    Current.wallet.refreshLocal()
                    NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
                }
                Current.navigate.to(tabNavigationRequest)
            }
            }, onError: { [weak self] error in
                self?.displaySimplePopup(title: L10n.errorTitle, message: error?.localizedDescription)
                completion()
        })
    }
    
    private func addGhostCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil, existingMembershipCard: CD_MembershipCard?) throws {
        // Setup with both
        populateCard(with: formFields, checkboxes: checkboxes, columnKind: .add)
        populateCard(with: formFields, checkboxes: checkboxes, columnKind: .register)
        
        guard var model = membershipCardPostModel else {
            return
        }
        
        if existingMembershipCard != nil {
            model.membershipPlan = nil
        }
        
        repository.postGhostCard(parameters: model, existingMembershipCard: existingMembershipCard, onSuccess: { (response) in
            guard let card = response else {
                Current.wallet.refreshLocal()
                NotificationCenter.default.post(name: .didAddMembershipCard, object: nil)
                return
            }
            
            // Navigate to LCD for the new card behind the modal
            let lcdViewController = ViewControllerFactory.makeLoyaltyCardDetailViewController(membershipCard: card)
            let lcdNavigationRequest = PushNavigationRequest(viewController: lcdViewController)
            let tabNavigationRequest = TabBarNavigationRequest(tab: .loyalty, popToRoot: true, backgroundPushNavigationRequest: lcdNavigationRequest)
            Current.navigate.to(tabNavigationRequest)

            if card.membershipPlan?.isPLL == true {
                PllLoyaltyInAppReviewableJourney().begin()

                let viewController = ViewControllerFactory.makePllViewController(membershipCard: card, journey: .newCard)
                let navigationRequest = PushNavigationRequest(viewController: viewController, hidesBackButton: true)
                Current.navigate.to(navigationRequest)
            } else {
                Current.navigate.close()
            }
        }) { (error) in
            self.displaySimplePopup(title: L10n.errorTitle, message: error?.localizedDescription)
        }
    }
    
    private func populateCard(with formFields: [FormField], checkboxes: [CheckboxView]? = nil, columnKind: FormField.ColumnKind) {
        formFields.forEach {
            if $0.columnKind == columnKind {
                addFieldToCard(formField: $0)
            }
        }
        checkboxes?.forEach {
            if $0.columnKind == columnKind && $0.columnKind != FormField.ColumnKind.planDocument {
                addCheckboxToCard(checkbox: $0)
            }
        }
    }
    
    func convertToDictionary(from text: String) throws -> [String: Any]? {
        guard let data = text.data(using: .utf8) else { return [:] }
        let anyResult: Any = try JSONSerialization.jsonObject(with: data, options: [])
        return anyResult as? [String: Any]
    }
    
    func setFields(fields: [InputValidation]) {
        self.fieldsViews = fields
    }
    
    private func encryptSensitiveField(_ value: String?) -> String? {
        if let encryptedValue = SecureUtility.encryptedSensitiveFieldValue(value) {
            return encryptedValue
        } else {
            SentryService.triggerException(.invalidLoyaltyCardPayload(.failedToEncyptPassword))
        }
        return nil
    }
    
    func addFieldToCard(formField: FormField) {
        let isSensitive = formField.fieldType == .sensitive
        switch formField.columnKind {
        case .add:
            let addFieldsArray = membershipCardPostModel?.account?.addFields
            if let existingField = addFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = isSensitive ? encryptSensitiveField(formField.value) : formField.value
            } else {
                let model = PostModel(column: formField.title, value: isSensitive ? encryptSensitiveField(formField.value) : formField.value)
                membershipCardPostModel?.account?.addField(model, to: .add)
            }
        case .auth:
            let authoriseFieldsArray = membershipCardPostModel?.account?.authoriseFields
            if let existingField = authoriseFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = isSensitive ? encryptSensitiveField(formField.value) : formField.value
            } else {
                let model = PostModel(column: formField.title, value: isSensitive ? encryptSensitiveField(formField.value) : formField.value)
                membershipCardPostModel?.account?.addField(model, to: .auth)
            }
        case .enrol:
            let enrolFieldsArray = membershipCardPostModel?.account?.enrolFields
            if let existingField = enrolFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = isSensitive ? encryptSensitiveField(formField.value) : formField.value
            } else {
                let model = PostModel(column: formField.title, value: isSensitive ? encryptSensitiveField(formField.value) : formField.value)
                membershipCardPostModel?.account?.addField(model, to: .enrol)
            }
        case .register:
            let registrationFieldsArray = membershipCardPostModel?.account?.registrationFields
            if let existingField = registrationFieldsArray?.first(where: { $0.column == formField.title }) {
                existingField.value = isSensitive ? encryptSensitiveField(formField.value) : formField.value
            } else {
                let model = PostModel(column: formField.title, value: isSensitive ? encryptSensitiveField(formField.value) : formField.value)
                membershipCardPostModel?.account?.addField(model, to: .registration)
            }
        default:
            break
        }
    }
    
    func addCheckboxToCard(checkbox: CheckboxView) {
        switch checkbox.columnKind {
        case .add:
            let addFieldsArray = membershipCardPostModel?.account?.addFields
            if let existingField = addFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .add)
            }
        case .auth:
            let authoriseFieldsArray = membershipCardPostModel?.account?.authoriseFields
            if let existingField = authoriseFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .auth)
            }
        case .enrol:
            let enrolFieldsArray = membershipCardPostModel?.account?.enrolFields
            if let existingField = enrolFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .enrol)
            }
        case .register:
            let registerFieldsArray = membershipCardPostModel?.account?.registrationFields
            if let existingField = registerFieldsArray?.first(where: { $0.column == checkbox.columnName }) {
                existingField.value = String(checkbox.isValid)
            } else {
                let model = PostModel(column: checkbox.columnName, value: String(checkbox.isValid))
                membershipCardPostModel?.account?.addField(model, to: .registration)
            }
        default:
            break
        }
    }
    
    func reloadWithGhostCardFields() {
        let newFormPurpose: FormPurpose = formPurpose == .addFailed ? .patchGhostCard : .ghostCard
        let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: membershipPlan, formPurpose: newFormPurpose, existingMembershipCard: existingMembershipCard)
        let navigationRequest = PushNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func openWebView(withUrlString url: URL) {
        // TODO: - Change name of function
        
//        let urlString = url.absoluteString
//        let viewController = ViewControllerFactory.makeWebViewController(urlString: urlString)
//        let navigationRequest = ModalNavigationRequest(viewController: viewController)
//        Current.navigate.to(navigationRequest)
        
        do {
            let contents = try String(contentsOf: url)
            print(contents)
            
            let data = Data(contents.utf8)
            if let attributedString = try? NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
                // Format all text
                attributedString.addAttribute(.font, value: UIFont.bodyTextSmall, range: NSRange(location: 0, length: attributedString.string.count - 1))
                
                // Format title
                let titleString = contents.slice(from: "<h1>", to: "</h1>")
                let formattedTitle = titleString?.replacingOccurrences(of: "&amp;", with: "&")
                if let titleRange = attributedString.string.range(of: formattedTitle ?? "") {
                    let nsTitleRange = NSRange(titleRange, in: attributedString.string)
                    attributedString.addAttribute(.font, value: UIFont.headline, range: nsTitleRange)
                }
                
                // Format subtitles
                let paragraphs = contents.components(separatedBy: "<h2>")
                for paragraph in paragraphs {
                    let finalParagraph = "<h2>" + paragraph
                    print(finalParagraph)
                    print("______________________")
                    
                    let subtitle = finalParagraph.slice(from: "<h2>", to: "</h2>")
                    if let subtitleRange = attributedString.string.range(of: subtitle ?? "") {
                        let nsSubtitleRange = NSRange(subtitleRange, in: attributedString.string)
                        attributedString.addAttribute(.font, value: UIFont.subtitle, range: nsSubtitleRange)
                    }
                }
                
                // Present modal
                let modalConfig = ReusableModalConfiguration(text: attributedString)
                let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: modalConfig)
                let navigationRequest = ModalNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
            }
        } catch {
            print("Contents could not be loaded")
        }
    }
    
    func toReusableTemplate(title: String, description: String) {
        let attributedString = NSMutableAttributedString()
        let attributedTitle = NSAttributedString(string: title + "\n", attributes: [NSAttributedString.Key.font: UIFont.headline])
        let attributedBody = NSAttributedString(string: description, attributes: [NSAttributedString.Key.font: UIFont.bodyTextLarge])
        attributedString.append(attributedTitle)
        attributedString.append(attributedBody)
        
        let configuration = ReusableModalConfiguration(title: title, text: attributedString)
        let viewController = ViewControllerFactory.makeReusableTemplateViewController(configuration: configuration)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func brandHeaderWasTapped() {
        let viewController = ViewControllerFactory.makeAboutMembershipPlanViewController(membershipPlan: membershipPlan)
        let navigationRequest = ModalNavigationRequest(viewController: viewController)
        Current.navigate.to(navigationRequest)
    }
    
    func displaySimplePopup(title: String?, message: String?) {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: title, message: message)
        Current.navigate.to(AlertNavigationRequest(alertController: alert))
    }
    
    func toLoyaltyScanner(forPlan plan: CD_MembershipPlan, delegate: BarcodeScannerViewControllerDelegate?) {
        let viewController = ViewControllerFactory.makeLoyaltyScannerViewController(forPlan: plan, delegate: delegate)
        PermissionsUtility.launchLoyaltyScanner(viewController) {
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
}
