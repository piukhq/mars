//
//  BrowseBrandsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

fileprivate struct Constants {
    static let tableViewHeaderHeight: CGFloat = 47.0
    static let searchIconLeftPadding = 12
    static let searchIconTopPadding = 13
    static let searchIconSideSize = 14
    static let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
}

class BrowseBrandsViewController: BinkTrackableViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchTextField: BinkTextField!
    @IBOutlet private weak var noMatchesLabel: UILabel!
    @IBOutlet private weak var searchTextFieldContainer: UIView!
    @IBOutlet private weak var topStackView: UIStackView!
    @IBOutlet private weak var noMatchesLabelTopConstraint: NSLayoutConstraint!
    
    private var filtersVisible = false
    private var selectedCollectionViewIndexPaths = [IndexPath]()
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.alwaysBounceVertical = false
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.estimatedItemSize = CGSize(width: (self.view.frame.width - 50) / 2, height: 40.0)
        return layout
    }()
    
    private var filterViewHeight: CGFloat {
        let height = CGFloat(round(Double(self.viewModel.filters.count) / 2) * 40)
        return height + 10
    }
    
    let viewModel: BrowseBrandsViewModel
    private var selectedFilters: [String]
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setScreenName(trackedScreen: .browseBrands)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
        
        let filtersButton = UIBarButtonItem(title: "filters_button_title".localized, style: .plain, target: self, action: #selector(filtersButtonTaped))
        navigationItem.rightBarButtonItem = filtersButton
        navigationItem.rightBarButtonItem?.tintColor = .blue
        
        self.title = "browse_brands_title".localized
    }
    
    private func configureCollectionView() {
        collectionView.register(FilterBrandsCollectionViewCell.self, asNib: true)
        collectionView.delegate = self
        collectionView.dataSource = self
        let collectionFrameY = topStackView.frame.maxY + LayoutHelper.heightForNavigationBar(navigationController?.navigationBar)
        collectionView.frame = CGRect(x: 25, y: collectionFrameY, width: view.frame.width - 50, height: 0.0)
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
        let searchImageView = UIImageView(frame:
            CGRect(x: Constants.searchIconLeftPadding,
                   y: Constants.searchIconTopPadding,
                   width: Constants.searchIconSideSize,
                   height: Constants.searchIconSideSize))
        
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
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        if filtersVisible {
            tableView.contentInset = UIEdgeInsets(top: filterViewHeight, left: 0, bottom: 0, right: 0)
        } else {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func filtersButtonTaped() {
        let tableContentOffsetY = tableView.contentOffset.y
        if filtersVisible {
            hideFilters(with: tableContentOffsetY)
        } else {
            displayFilters(with: tableContentOffsetY)
        }
        filtersVisible = !filtersVisible
    }
    
    private func hideFilters(with contentOffsetY: CGFloat) {
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
        }
    }
    
    private func displayFilters(with contentOffsetY: CGFloat) {
        if !self.noMatchesLabel.isHidden {
            self.noMatchesLabelTopConstraint.constant = self.filterViewHeight
        }
        let frame = self.collectionView.frame
        UIView.animate(withDuration: 0.3, animations: {
            self.collectionView.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.width, height: self.filterViewHeight)
            self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: contentOffsetY - self.filterViewHeight)
            UIView.performWithoutAnimation {
                self.collectionView.performBatchUpdates(nil, completion: nil)
            }
           self.view.layoutIfNeeded()
        }) { [weak self] _ in
                self?.tableView.contentInset.top = self?.filterViewHeight ?? 0.0
        }
    }
    
    private func switchTableWithNoMatchesLabel() {
        tableView.isHidden = viewModel.shouldShowNoResultsLabel
        noMatchesLabelTopConstraint.constant = filtersVisible ? filterViewHeight : 0.0
        noMatchesLabel.isHidden = !viewModel.shouldShowNoResultsLabel
    }
    
    @objc private func popViewController() {
        viewModel.popViewController()
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
        
        if let brandName = membershipPlan.account?.companyName {
            switch indexPath.section {
            case 0:
                cell.configure(plan: membershipPlan, brandName: brandName)
                if indexPath.row == viewModel.getPllMembershipPlans().count - 1 {
                    cell.hideSeparatorView()
                }
                break
            case 1:
                cell.configure(plan: membershipPlan, brandName: brandName)
                if indexPath.row == viewModel.getNonPllMembershipPlans().count - 1 {
                    cell.hideSeparatorView()
                }
                break
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
        if string == "" && range.length > 0 {
            searchText = textField.text ?? ""
            searchText.popLast()
        } else {
            searchText = "\(textField.text ?? "")\(string)"
        }
        viewModel.searchText = searchText
        switchTableWithNoMatchesLabel()
        textField.textColor = searchText != "" ? .black : .greyFifty
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
        return CGSize(width: collectionView.bounds.width / 2 - 0.1, height: 40.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FilterBrandsCollectionViewCell
        cell.cellWasTapped = !cell.cellWasTapped
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
