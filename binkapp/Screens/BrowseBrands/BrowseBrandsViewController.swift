//
//  BrowseBrandsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import SwiftUI

fileprivate enum Constants {
    static let searchIconLeftPadding = 12
    static let searchIconTopPadding = 13
    static let searchIconSideSize = 14
    static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    static let marginPadding: CGFloat = 25.0
    static let filterCellHeight: CGFloat = 40.0
    static let filterViewHeightPadding: CGFloat = 10.0
}

class BrowseBrandsViewController: BinkViewController {
    @IBOutlet private weak var searchTextField: BinkTextField!
    @IBOutlet private weak var noMatchesLabel: UILabel!
    @IBOutlet private weak var searchTextFieldContainer: UIView!
    @IBOutlet private weak var topStackView: UIStackView!
    @IBOutlet private weak var noMatchesLabelTopConstraint: NSLayoutConstraint!
    
    private var filtersVisible = false
    private var selectedCollectionViewIndexPaths: [IndexPath] = []
    
    private var filtersButton: UIBarButtonItem?
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = CGSize(width: (self.view.frame.width - (Constants.marginPadding * 2)) / 2, height: Constants.filterCellHeight)
        return layout
    }()
    
    private lazy var textfieldShadowLayer: UIView = {
        let shadowLayer = UIView()
        shadowLayer.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        shadowLayer.layer.cornerRadius = searchTextField.bounds.height / 2
        shadowLayer.translatesAutoresizingMaskIntoConstraints = false
        shadowLayer.clipsToBounds = false
        shadowLayer.layer.applyDefaultBinkShadow()
        return shadowLayer
    }()
    
    private var filterViewHeight: CGFloat {
        let height = CGFloat(round(Double(self.viewModel.filters.count) / 2) * Double( Constants.filterCellHeight))
        return height + Constants.filterViewHeightPadding
    }
    
    private lazy var browseBrandsListView: UIHostingController<BrowseBrandsListView> = {
        let listView = BrowseBrandsListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: listView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.didMove(toParent: self)
        return hostingController
    }()
    
    private lazy var listViewTopConstraint: NSLayoutConstraint = {
        let constraint = browseBrandsListView.view.topAnchor.constraint(equalTo: topStackView.bottomAnchor)
        constraint.isActive = true
        return constraint
    }()
    
    let viewModel: BrowseBrandsViewModel
    private var selectedFilters: [String]
    private var didLayoutSubviews = false
    private var sectionToScrollTo: Int?
    private let visionUtility = VisionUtility()
    
    init(viewModel: BrowseBrandsViewModel, section: Int?) {
        self.viewModel = viewModel
        self.selectedFilters = viewModel.filters
        self.sectionToScrollTo = section
        super.init(nibName: "BrowseBrandsViewController", bundle: Bundle(for: BrowseBrandsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.delegate = self
        noMatchesLabel.font = UIFont.bodyTextLarge
        noMatchesLabel.text = L10n.noMatches
        
        configureSearchTextField()
        configureCollectionView()
        
        NSLayoutConstraint.activate([
            browseBrandsListView.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            browseBrandsListView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            browseBrandsListView.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            listViewTopConstraint
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        filtersButton = UIBarButtonItem(title: L10n.filtersButtonTitle, style: .plain, target: self, action: #selector(filtersButtonTapped))
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.systemGray, .font: UIFont.linkTextButtonNormal], for: .highlighted)
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        
        navigationItem.leftBarButtonItem = filtersButton
        
        self.title = L10n.browseBrandsTitle
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .browseBrands)
        scrollToSection()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        didLayoutSubviews = true
    }
    
    override func configureForCurrentTheme() {
        view.backgroundColor = Current.themeManager.color(for: .viewBackground)
        collectionView.backgroundColor = Current.themeManager.color(for: .viewBackground)
        topStackView.backgroundColor = Current.themeManager.color(for: .viewBackground)
        noMatchesLabel.textColor = Current.themeManager.color(for: .text)
        searchTextField.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        
        if didLayoutSubviews {
            collectionView.reloadData()
        }
    }
    
    private func configureCollectionView() {
        collectionView.register(FilterBrandsCollectionViewCell.self, asNib: true)
        collectionView.delegate = self
        collectionView.dataSource = self
        
        var collectionFrameY = topStackView.frame.maxY
        if navigationController?.modalPresentationStyle == .fullScreen || navigationController?.isBeingPresented == false {
            let notchDeviceCollectionFrameY = topStackView.frame.maxY + LayoutHelper.heightForNavigationBar(navigationController?.navigationBar)
            let nonNotchDeviceCollectionFrameY = topStackView.frame.maxY + LayoutHelper.statusBarHeight
            collectionFrameY = UIDevice.current.hasNotch ? notchDeviceCollectionFrameY : nonNotchDeviceCollectionFrameY
        }
        collectionView.frame = CGRect(x: Constants.marginPadding, y: collectionFrameY, width: view.frame.width - (Constants.marginPadding * 2), height: 0.0)
        view.addSubview(collectionView)
    }
    
    private func configureSearchTextField() {
        searchTextField.placeholder = L10n.search
        searchTextField.font = .textFieldInput
        searchTextField.textColor = .greyFifty
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.leftViewMode = .always
        searchTextField.autocapitalizationType = .words
        searchTextField.autocorrectionType = .no

        // Magnifying glass icon
        let searchIconView = UIView(frame: CGRect(x: 0, y: 0, width: searchTextField.frame.height, height: searchTextField.frame.height))
        let searchImageView = UIImageView(frame: CGRect(x: Constants.searchIconLeftPadding, y: Constants.searchIconTopPadding, width: Constants.searchIconSideSize, height: Constants.searchIconSideSize))
        
        searchImageView.contentMode = .scaleAspectFit
        searchImageView.image = Asset.search.image
        searchIconView.addSubview(searchImageView)
        
        searchTextField.leftView = searchIconView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func filtersButtonTapped() {
        if filtersVisible {
            hideFilters()
        } else {
            displayFilters()
        }
        filtersVisible.toggle()
    }
    
    private func hideFilters() {
        filtersButton?.isEnabled = false
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .disabled)
        
        if !self.noMatchesLabel.isHidden {
            self.noMatchesLabelTopConstraint.constant = 0.0
        }

        let frame = self.collectionView.frame
        listViewTopConstraint.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 0)
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.filtersButton?.isEnabled = true
            self?.filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        }
    }
    
    private func displayFilters() {
        if !self.noMatchesLabel.isHidden {
            self.noMatchesLabelTopConstraint.constant = self.filterViewHeight
        }

        filtersButton?.isEnabled = false
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .disabled)
        let frame = self.collectionView.frame
        listViewTopConstraint.constant = filterViewHeight
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.view.frame.width - (Constants.marginPadding * 2), height: self.filterViewHeight)
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates(nil, completion: nil)
            }
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.filtersButton?.isEnabled = true
            self?.filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        }
    }
    
    private func switchTableWithNoMatchesLabel() {
        browseBrandsListView.view.isHidden = viewModel.shouldShowNoResultsLabel
        noMatchesLabelTopConstraint.constant = filtersVisible ? filterViewHeight : 0.0
        noMatchesLabel.isHidden = !viewModel.shouldShowNoResultsLabel
    }
    
    private func scrollToSection() {
        guard var section = sectionToScrollTo, viewModel.numberOfSections() != 1 else { return }

        if viewModel.getPllMembershipPlans().isEmpty || viewModel.getSeeMembershipPlans().isEmpty {
            /// If there are no pll or see membership plans, section adjusted by -1 so that the correct section is scrolled to
            section -= 1
        }

        viewModel.scrollToSection = section
        sectionToScrollTo = nil
    }
    
    private func showError() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.loyaltyScannerFailedToDetectBarcode)
        self.present(alert, animated: true, completion: nil)
    }
}

extension BrowseBrandsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var searchText = ""
        if string.isEmpty && range.length > 0 {
            searchText = textField.text ?? ""
            searchText.removeLast()
        } else {
            searchText = "\(textField.text ?? "")\(string)"
        }
        viewModel.searchText = searchText
        switchTableWithNoMatchesLabel()
        textField.textColor = !searchText.isEmpty ? .black : .greyFifty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.searchText = ""
        switchTableWithNoMatchesLabel()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

extension BrowseBrandsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: FilterBrandsCollectionViewCell = collectionView.dequeue(indexPath: indexPath)
        cell.configureCell(with: viewModel.filters[indexPath.row])
        cell.cellWasTapped = selectedCollectionViewIndexPaths.contains(indexPath)
        if viewModel.filters.count.isMultiple(of: 2) {
            if indexPath.row == viewModel.filters.count - 2 || indexPath.row == viewModel.filters.count - 1 {
                cell.hideSeparator()
            }
        } else {
            if  indexPath.row == viewModel.filters.count - 1 {
                cell.hideSeparator()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 2), height: Constants.filterCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell: FilterBrandsCollectionViewCell = collectionView.cellForItem(at: indexPath) as? FilterBrandsCollectionViewCell else {
            fatalError("Couldn't load cell")
        }
        cell.cellWasTapped.toggle()
        if selectedCollectionViewIndexPaths.contains(indexPath) {
            if let index = selectedCollectionViewIndexPaths.firstIndex(of: indexPath) {
                selectedCollectionViewIndexPaths.remove(at: index)
            }
        } else {
            selectedCollectionViewIndexPaths.append(indexPath)
        }
        
        if let filter = cell.filterTitle, selectedFilters.contains(filter) {
            let index = selectedFilters.firstIndex(of: filter)
            selectedFilters.remove(at: index ?? 0)
        } else {
            selectedFilters.append(cell.filterTitle ?? "")
        }
        viewModel.selectedFilters = selectedFilters
        switchTableWithNoMatchesLabel()
    }
}

extension BrowseBrandsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        Current.navigate.close(animated: true) { [weak self] in
            guard let self = self else { return }
            self.visionUtility.detectBarcode(ciImage: image.ciImage(), completion: { barcode in
                guard let barcode = barcode else {
                    self.visionUtility.detectBarcodeString(from: image.ciImage(), completion: { barcode in
                        guard let barcode = barcode else {
                            DispatchQueue.main.async {
                                self.visionUtility.showError(barcodeDetected: false)
                            }
                            return
                        }
                        self.handleBarcodeDetection(barcode)
                    })
                    return
                }
                self.handleBarcodeDetection(barcode)
            })
        }
    }
    
    private func handleBarcodeDetection(_ barcode: String) {
        Current.wallet.identifyMembershipPlanForBarcode(barcode) { [weak self] plan in
            guard let plan = plan else {
                self?.visionUtility.showError(barcodeDetected: false)
                return
            }
            
            Current.navigate.close(animated: true) {
                let prefilledValues = FormDataSource.PrefilledValue(commonName: .barcode, value: barcode)
                let viewController = ViewControllerFactory.makeAuthAndAddViewController(membershipPlan: plan, formPurpose: .addFromScanner, existingMembershipCard: nil, prefilledFormValues: [prefilledValues])
                let navigationRequest = PushNavigationRequest(viewController: viewController)
                Current.navigate.to(navigationRequest)
                HapticFeedbackUtil.giveFeedback(forType: .notification(type: .success))
            }
        }
    }
}
