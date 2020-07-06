//
//  AuthAndAddViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import NotificationCenter

class AuthAndAddViewController: BaseFormViewController {    
    private struct Constants {
        static let postCollectionViewPadding: CGFloat = 15.0
        static let cardPadding: CGFloat = 30.0
        static let cellErrorLabelSafeSpacing: CGFloat = 60.0
    }
    
    private lazy var brandHeaderView: BrandHeaderView = {
        let brandHeader = BrandHeaderView()
        brandHeader.heightAnchor.constraint(equalToConstant: 110).isActive = true
        return brandHeader
    }()

    private lazy var floatingButtons: BinkPrimarySecondaryButtonView = {
        let floatingButtons = BinkPrimarySecondaryButtonView()
        floatingButtons.configure(primaryButtonTitle: viewModel.buttonTitle, secondaryButtonTitle: nil)
        floatingButtons.primaryButton.isEnabled = self.dataSource.fullFormIsValid
        floatingButtons.delegate = self
        floatingButtons.translatesAutoresizingMaskIntoConstraints = false
        return floatingButtons
    }()
    
    private let viewModel: AuthAndAddViewModel
    
    init(viewModel: AuthAndAddViewModel) {
        self.viewModel = viewModel
        let datasource = FormDataSource(authAdd: viewModel.getMembershipPlan(), formPurpose: viewModel.formPurpose)
        super.init(title: "login".localized, description: "", dataSource: datasource)
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialContentOffset = stackScrollView.contentOffset
        switch viewModel.formPurpose {
        case .add, .addFailed, .addFromScanner: setScreenName(trackedScreen: .addAuthForm)
        case .signUp, .signUpFailed: setScreenName(trackedScreen: .enrolForm)
        case .ghostCard, .patchGhostCard: setScreenName(trackedScreen: .registrationForm)
        }
    }
    
    func setNavigationBar() {
        let closeButton = UIBarButtonItem(title: "cancel".localized, style: .plain, target: self, action: #selector(popToRootScreen))
        closeButton.tintColor = .black
        self.navigationItem.setRightBarButton(closeButton, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        self.navigationItem.leftBarButtonItem = backButton
        
        navigationItem.setHidesBackButton(false, animated: true)
    }
    
    // MARK: - Layout
    
    func configureLayout() {
        view.addSubview(floatingButtons)
        NSLayoutConstraint.activate([
            floatingButtons.leftAnchor.constraint(equalTo: view.leftAnchor),
            floatingButtons.rightAnchor.constraint(equalTo: view.rightAnchor),
            floatingButtons.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -LayoutHelper.PrimarySecondaryButtonView.bottomPadding),
        ])
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
    
    @objc func popViewController() {
        viewModel.popViewController()
    }
    
    @objc func popToRootScreen() {
        viewModel.popToRootViewController()
    }
    
    override func formValidityUpdated(fullFormIsValid: Bool) {
        floatingButtons.primaryButton.isEnabled = fullFormIsValid
    }
    
    override func checkboxView(_ checkboxView: CheckboxView, didTapOn URL: URL) {
        viewModel.openWebView(withUrlString: URL)
    }
}

extension AuthAndAddViewController: BarcodeScannerViewControllerDelegate {
    func barcodeScannerViewController(_ viewController: BarcodeScannerViewController, didScanBarcode barcode: String, forMembershipPlan membershipPlan: CD_MembershipPlan, completion: (() -> Void)?) {
        viewController.dismiss(animated: true) {
            self.dataSource = FormDataSource(authAdd: self.viewModel.getMembershipPlan(), formPurpose: .addFromScanner(barcode: barcode), delegate: self)
        }
    }
    
    func barcodeScannerViewControllerShouldEnterManually(_ viewController: BarcodeScannerViewController, completion: (() -> Void)?) {
        viewController.dismiss(animated: true, completion: nil)
    }
}

extension AuthAndAddViewController: BinkPrimarySecondaryButtonViewDelegate {
    func binkFloatingButtonsPrimaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        floatingButtons.primaryButton.startLoading()
        try? viewModel.addMembershipCard(with: dataSource.fields, checkboxes: dataSource.checkboxes, completion: {
            floatingButtons.primaryButton.stopLoading()
        })
    }
    
    func binkFloatingButtonsSecondaryButtonWasTapped(_ floatingButtons: BinkPrimarySecondaryButtonView) {
        //TODO: Re-enable this functionality at a later date, this has been disabled for MS1: 10/02/19 because the 1.1.4 API doesn't consistently support ghost card registration
        
//        let fields = viewModel.getMembershipPlan().featureSet?.formattedLinkingSupport
//        guard (fields?.contains(where: { $0.value == LinkingSupportType.registration.rawValue }) ?? false) else {
            viewModel.toReusableTemplate(title: "registration_unavailable_title".localized, description: "registration_unavailable_description".localized)
//            return
//        }
//        viewModel.reloadWithGhostCardFields()
//        }
//        viewModel.reloadWith(newFormPuropse: .ghostCard)
    }
}

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
