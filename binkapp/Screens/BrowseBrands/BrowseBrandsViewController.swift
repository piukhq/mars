//
//  BrowseBrandsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

fileprivate enum Constants {
    static let tableViewHeaderHeight: CGFloat = 47.0
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
    
    private var filterViewHeight: CGFloat {
        let height = CGFloat(round(Double(self.viewModel.filters.count) / 2) * Double( Constants.filterCellHeight))
        return height + Constants.filterViewHeightPadding
    }
    
    let viewModel: BrowseBrandsViewModel
    private var selectedFilters: [String]
    private var didLayoutSubviews = false
    
    init(viewModel: BrowseBrandsViewModel) {
        self.viewModel = viewModel
        self.selectedFilters = viewModel.filters
        super.init(nibName: "BrowseBrandsViewController", bundle: Bundle(for: BrowseBrandsViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "BrandTableViewCell", bundle: Bundle(for: BrandTableViewCell.self)), forCellReuseIdentifier: "BrandTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = Constants.contentInset
        searchTextField.delegate = self
        viewModel.delegate = self
        
        noMatchesLabel.font = UIFont.bodyTextLarge
        noMatchesLabel.text = "no_matches".localized
        
        configureSearchTextField()
        configureCollectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        filtersButton = UIBarButtonItem(title: "filters_button_title".localized, style: .plain, target: self, action: #selector(filtersButtonTapped))
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.systemGray, .font: UIFont.linkTextButtonNormal], for: .highlighted)
        filtersButton?.setTitleTextAttributes([.foregroundColor: UIColor.blueAccent, .font: UIFont.linkTextButtonNormal], for: .normal)
        
        navigationItem.leftBarButtonItem = filtersButton
        
        self.title = "browse_brands_title".localized
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setScreenName(trackedScreen: .browseBrands)
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
        searchTextField.placeholder = "search".localized
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
        searchImageView.image = UIImage(named: "search")
        searchIconView.addSubview(searchImageView)
        
        searchTextField.leftView = searchIconView
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
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
        
        let membershipPlan = viewModel.getMembershipPlan(for: indexPath)
        
        if let brandName = membershipPlan.account?.companyName, let brandExists = viewModel.existingCardsPlanIDs?.contains(membershipPlan.id) {
            switch indexPath.section {
            case 0:
                cell.configure(plan: membershipPlan, brandName: brandName, brandExists: brandExists)
                if indexPath.row == (viewModel.getPllMembershipPlans().isEmpty ? (viewModel.getSeeMembershipPlans().isEmpty ? viewModel.getStoreMembershipPlans().count - 1 : viewModel.getSeeMembershipPlans().count - 1) : viewModel.getPllMembershipPlans().count - 1) {
                    cell.hideSeparatorView()
                }
            case 1:
                cell.configure(plan: membershipPlan, brandName: brandName, brandExists: brandExists)
                if indexPath.row == (viewModel.getPllMembershipPlans().isEmpty ? viewModel.getStoreMembershipPlans().count - 1 : (viewModel.getSeeMembershipPlans().isEmpty ? viewModel.getStoreMembershipPlans().count - 1 : viewModel.getSeeMembershipPlans().count - 1)) {
                    cell.hideSeparatorView()
                }
            case 2:
                cell.configure(plan: membershipPlan, brandName: brandName, brandExists: brandExists)
                if indexPath.row == viewModel.getStoreMembershipPlans().count - 1 {
                    cell.hideSeparatorView()
                }
            default:
                break
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: Constants.tableViewHeaderHeight))
        titleLabel.font = UIFont.headline
        titleLabel.text = viewModel.getSectionTitleText(section: section)
        titleLabel.textColor = Current.themeManager.color(for: .text)
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.tableViewHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let membershipPlan = viewModel.getMembershipPlan(for: indexPath)
        viewModel.toAddOrJoinScreen(membershipPlan: membershipPlan)
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
