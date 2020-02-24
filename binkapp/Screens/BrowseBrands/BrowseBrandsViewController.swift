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
    
    let viewModel: BrowseBrandsViewModel
    
    init(viewModel: BrowseBrandsViewModel) {
        self.viewModel = viewModel
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        let backButton = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        navigationItem.leftBarButtonItem = backButton
        
        //TODO: uncomment this to display the Filters button
//        let filtersButton = UIBarButtonItem(title: "filters_button_title".localized, style: .plain, target: self, action: #selector(notImplementedPopup))
//        navigationItem.rightBarButtonItem = filtersButton
//        navigationItem.rightBarButtonItem?.tintColor = .black
        
        self.title = "browse_brands_title".localized
    }
    
    private func configureSearchTextField() {
        searchTextField.placeholder = "search".localized
        searchTextField.font = .textFieldInput
        searchTextField.textColor = .greyFifty
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.leftViewMode = .always
        searchTextField.autocapitalizationType = .words
        
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
    
    @objc func notImplementedPopup() {
        let alert = UIAlertController(title: "Feature not implemented", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
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
                cell.configure(plan: membershipPlan, brandName: brandName, description: true)
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
        guard viewModel.filteredData.isEmpty else {
            return nil
        }
        
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
        if viewModel.filteredData.isEmpty {
            return Constants.tableViewHeaderHeight
        }
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let membershipPlan = viewModel.getMembershipPlan(for: indexPath)
        viewModel.toAddOrJoinScreen(membershipPlan: membershipPlan)
    }
}

extension BrowseBrandsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        viewModel.filteredData = []
        
        var searchText = ""
        if string == "" && range.length > 0 {
            searchText = textField.text ?? ""
            searchText.popLast()
        } else {
            searchText = "\(textField.text ?? "")\(string)"
        }
        
        viewModel.getMembershipPlans().forEach { plan in
            guard let companyName = plan.account?.companyName else {
                return
            }
            
            if companyName.localizedCaseInsensitiveContains(searchText) {
                viewModel.filteredData.append(plan)
            }
        }
        if !searchText.isEmpty && viewModel.filteredData.isEmpty {
            tableView.isHidden = true
            noMatchesLabel.isHidden = false
        } else {
            tableView.isHidden = false
            noMatchesLabel.isHidden = true
        }
        
        textField.textColor = searchText != "" ? .black : .greyFifty
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        viewModel.filteredData = []
        tableView.isHidden = false
        noMatchesLabel.isHidden = true
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
