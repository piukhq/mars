//
//  AuthAndAddViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import NotificationCenter

class AuthAndAddViewController: BaseFormViewController {
    private enum Constants {
        static let postCollectionViewPadding: CGFloat = 15.0
        static let cardPadding: CGFloat = 30.0
        static let cellErrorLabelSafeSpacing: CGFloat = 60.0
    }
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return brandHeader
    }()
    
    private lazy var primaryButton: BinkButton = {
        return BinkButton(type: .gradient, title: viewModel.buttonTitle, enabled: dataSource.fullFormIsValid) { [weak self] in
            self?.handlePrimaryButtonTap()
        }
    }()
    
    private let viewModel: AuthAndAddViewModel
    
    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        let dataSource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose, prefilledValues: viewModel.prefilledFormValues)
        super.init(title: L10n.login, description: "", dataSource: dataSource)
        dataSource.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        configureUI()
        configureLayout()
        stackScrollView.insert(arrangedSubview: brandHeaderView, atIndex: 0, customSpacing: Constants.cardPadding)
        collectionView.delegate = self
        
        // If we enter this view controller from the scanner, we should safely remove the barcode scanner from the stack
        if viewModel.shouldRemoveScannerFromStack {
            navigationController?.removeViewControllerBehind(self, ifViewControllerBehindIsOfType: BarcodeScannerViewController.self)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialContentOffset = stackScrollView.contentOffset
        switch viewModel.formPurpose {
        case .add, .addFailed, .addFromScanner: setScreenName(trackedScreen: .addAuthForm)
        case .signUp, .signUpFailed:
            setScreenName(trackedScreen: .enrolForm)
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.viewModel.configureAttributedStrings()
            }
        case .ghostCard, .patchGhostCard: setScreenName(trackedScreen: .registrationForm)
        }
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
        let membershipPlan = viewModel.getMembershipPlan()
        brandHeaderView.configure(plan: membershipPlan, delegate: self)
    }
    
    func setNavigationBar() {
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    // MARK: - Layout
    
    func configureLayout() {
        footerButtons = [primaryButton]
    }
    
    func configureUI() {
        let membershipPlan = viewModel.getMembershipPlan()
        
        brandHeaderView.configure(plan: membershipPlan, delegate: self)
        
        titleLabel.text = viewModel.title
        titleLabel.font = UIFont.headline
        
        descriptionLabel.text = viewModel.getDescription()
        descriptionLabel.font = UIFont.bodyTextLarge
        descriptionLabel.isHidden = viewModel.getDescription() == nil
    }
    
    private func handlePrimaryButtonTap() {
        primaryButton.toggleLoading(isLoading: true)
        try? viewModel.addMembershipCard(with: dataSource.fields, checkboxes: dataSource.checkboxes, completion: { [weak self] in
            self?.primaryButton.toggleLoading(isLoading: false)
        })
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        primaryButton.enabled = fullFormIsValid
    }
    
    override func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {
        viewModel.presentPlanDocumentsModal(withUrl: URL)
    }
}

extension AuthAndAddViewController: BarcodeScannerViewControllerDelegate {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        viewController.dismiss(animated: true) {
            var prefilledValues = self.dataSource.fields.filter { $0.fieldCommonName != .barcode && $0.fieldCommonName != .cardNumber }.map {
                FormDataSource.PrefilledValue(commonName: $0.fieldCommonName, value: $0.value)
            }
            prefilledValues.append(FormDataSource.PrefilledValue(commonName: .barcode, value: barcode))
            self.dataSource = FormDataSource(authAdd: self.viewModel.getMembershipPlan(), formPurpose: .addFromScanner, delegate: self, prefilledValues: prefilledValues)
            self.viewModel.formPurpose = .addFromScanner
            self.formValidityUpdated(fullFormIsValid: self.dataSource.fullFormIsValid)
        }
    }
    
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        Current.navigate.close()
    }
}

//extension AuthAndAddViewController: BinkPrimarySecondaryButtonViewDelegate {    
//    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
//        //TODO: Re-enable this functionality at a later date, this has been disabled for MS1: 10/02/19 because the 1.1.4 API doesn't consistently support ghost card registration
//        
//        //        let fields = viewModel.getMembershipPlan().featureSet?.formattedLinkingSupport
//        //        guard (fields?.contains(where: { $0.value == LinkingSupportType.registration.rawValue }) ?? false) else {
//        viewModel.toReusableTemplate(title: "registration_unavailable_title".localized, description: "registration_unavailable_description".localized)
//        //            return
//        //        }
//        //        viewModel.reloadWithGhostCardFields()
//        //        }
//        //        viewModel.reloadWith(newFormPuropse: .ghostCard)
//    }
//}

extension AuthAndAddViewController: FormDataSourceDelegate {
    func formDataSource(_ dataSource: FormDataSource, textField: UITextField, shouldChangeTo newValue: String?, in range: NSRange, for field: FormField) -> Bool {
        return true
    }
    
    func formDataSourceShouldScrollToBottom(_ dataSource: FormDataSource) {
        let y = stackScrollView.contentSize.height - stackScrollView.bounds.size.height + stackScrollView.contentInset.bottom
        let offset = CGPoint(x: 0, y: y)
        stackScrollView.setContentOffset(offset, animated: true)
    }
    
    func formDataSource(_ dataSource: FormDataSource, shouldPresentLoyaltyScannerForPlan plan: CD_MembershipPlan) {
        viewModel.toLoyaltyScanner(forPlan: plan, delegate: self)
    }
    
    func formDataSourceShouldRefresh(_ dataSource: FormDataSource) {
        let prefilledValues = self.dataSource.fields.filter { $0.fieldCommonName != .barcode && $0.fieldCommonName != .cardNumber }.map {
            FormDataSource.PrefilledValue(commonName: $0.fieldCommonName, value: $0.value)
        }
        
        self.dataSource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: .add, delegate: self, prefilledValues: prefilledValues)
        viewModel.formPurpose = .add
        formValidityUpdated(fullFormIsValid: self.dataSource.fullFormIsValid)
    }
}

extension AuthAndAddViewController: LoyaltyButtonDelegate {
    func brandHeaderViewWasTapped(_ brandHeaderView: BrandHeaderView) {
        viewModel.brandHeaderWasTapped()
    }
}

extension AuthAndAddViewController: FormCollectionViewCellDelegate {
    func formCollectionViewCell(_ cell: FormCollectionViewCell, didSelectField: UITextField) {
        let cellOrigin = collectionView.convert(cell.frame.origin, to: view)
        self.selectedCellYOrigin = cellOrigin.y
        selectedCellHeight = cell.isValidationLabelHidden ? cell.frame.size.height + Constants.cellErrorLabelSafeSpacing : cell.frame.size.height
    }
    
    func formCollectionViewCell(_ cell: FormCollectionViewCell, shouldResignTextField textField: UITextField) {}
}
