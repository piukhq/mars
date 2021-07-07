//
//  BrowseBrandsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

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
    @IBOutlet private weak var tableView: UITableView!
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
    
    let viewModel: BrowseBrandsViewModel
    private var selectedFilters: [String]
    private var didLayoutSubviews = false
    private var sectionToScrollTo: Int?
    
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
        tableView.register(BrandTableViewCell.self, asNib: true)
        tableView.register(HeaderTableViewCell.self, asNib: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = Constants.contentInset
        searchTextField.delegate = self
        viewModel.delegate = self
        
        noMatchesLabel.font = UIFont.bodyTextLarge
        noMatchesLabel.text = L10n.noMatches
        
        configureSearchTextField()
        configureCollectionView()
                
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
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
            tableView.reloadData()
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
        
        if #available(iOS 14, *) {} else {
            /// iOS 13
            view.addSubview(textfieldShadowLayer)
            NSLayoutConstraint.activate([
                textfieldShadowLayer.leadingAnchor.constraint(equalTo: searchTextField.leadingAnchor),
                textfieldShadowLayer.topAnchor.constraint(equalTo: searchTextField.topAnchor),
                textfieldShadowLayer.heightAnchor.constraint(equalTo: searchTextField.heightAnchor),
                textfieldShadowLayer.widthAnchor.constraint(equalTo: searchTextField.widthAnchor)
            ])
            view.sendSubviewToBack(textfieldShadowLayer)
        }
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if filtersVisible {
                tableView.contentInset = UIEdgeInsets(top: filterViewHeight, left: 0, bottom: keyboardSize.height, right: 0)
            } else {
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            }
        }
    }
    
    @objc private func keyboardDidHide(notification: NSNotification) {
        if filtersVisible {
            tableView.contentInset = UIEdgeInsets(top: filterViewHeight, left: 0, bottom: 0, right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func filtersButtonTapped() {
        let tableContentOffsetY = tableView.contentOffset.y
        if filtersVisible {
            hideFilters(with: tableContentOffsetY)
        } else {
            displayFilters(with: tableContentOffsetY)
        }
        filtersVisible.toggle()
    }
    
    private func hideFilters(with contentOffsetY: CGFloat) {
        filtersButton?.isEnabled = false
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .disabled)
        
        if !self.noMatchesLabel.isHidden {
            self.noMatchesLabelTopConstraint.constant = 0.0
        }

        let frame = self.collectionView.frame
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: 0)
            self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: contentOffsetY + self.filterViewHeight)
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.tableView.contentInset.top = 0.0
            self?.filtersButton?.isEnabled = true
            self?.filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        }
    }
    
    private func displayFilters(with contentOffsetY: CGFloat) {
        if !self.noMatchesLabel.isHidden {
            self.noMatchesLabelTopConstraint.constant = self.filterViewHeight
        }

        filtersButton?.isEnabled = false
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .disabled)
        let frame = self.collectionView.frame
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.view.frame.width - (Constants.marginPadding * 2), height: self.filterViewHeight)
            self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: contentOffsetY - self.filterViewHeight)
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates(nil, completion: nil)
            }
            self.view.layoutIfNeeded()
        }) { [weak self] _ in
            self?.tableView.contentInset.top = self?.filterViewHeight ?? 0.0
            self?.filtersButton?.isEnabled = true
            self?.filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        }
    }
    
    private func switchTableWithNoMatchesLabel() {
        tableView.isHidden = viewModel.shouldShowNoResultsLabel
        noMatchesLabelTopConstraint.constant = filtersVisible ? filterViewHeight : 0.0
        noMatchesLabel.isHidden = !viewModel.shouldShowNoResultsLabel
    }
    
    private func scrollToSection() {
        guard var section = sectionToScrollTo, viewModel.numberOfSections() != 1 else { return }

        if viewModel.getPllMembershipPlans().isEmpty || viewModel.getSeeMembershipPlans().isEmpty {
            /// If there are no pll or see membership plans, section adjusted by -1 so that the correct section is scrolled to
            section -= 1
        }
        
        let indexPath = IndexPath(row: NSNotFound, section: section)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        sectionToScrollTo = nil
    }
}

extension BrowseBrandsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfRowsFor(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BrandTableViewCell = tableView.dequeue(indexPath: indexPath)
        
        guard let membershipPlan = viewModel.getMembershipPlan(for: indexPath) else { return cell }
        
        if let brandName = membershipPlan.account?.companyName, let brandExists = viewModel.existingCardsPlanIDs?.contains(membershipPlan.id) {
            cell.configure(plan: membershipPlan, brandName: brandName, brandExists: brandExists, indexPath: indexPath)
        }
        
        if tableView.cellAtIndexPathIsLastInSection(indexPath) {
            cell.hideSeparatorView()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderTableViewCell") as? HeaderTableViewCell else { return nil }
        headerCell.configure(section: section, viewModel: viewModel)
        return headerCell
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let membershipPlan = viewModel.getMembershipPlan(for: indexPath) else { return }
        viewModel.toAddOrJoinScreen(membershipPlan: membershipPlan)
        tableView.deselectRow(at: indexPath, animated: true)
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
        tableView.reloadData()
        view.endEditing(true)
        return true
    }
}

extension BrowseBrandsViewController: BrowseBrandsViewModelDelegate {
    func browseBrandsViewModel(_ viewModel: BrowseBrandsViewModel, didUpdateFilteredData filteredData: [CD_MembershipPlan]) {
        tableView.reloadData()
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
