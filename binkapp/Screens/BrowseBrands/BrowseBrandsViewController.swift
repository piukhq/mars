//
//  BrowseBrandsViewController.swift
//  binkapp
//
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class BrowseBrandsViewController: UIViewController {
    @IBOutlet private weak var searchTextField: BinkTextField!
    @IBOutlet private weak var tableView: UITableView!
    
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
        
        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        
        let filtersButton = UIBarButtonItem(title: "filters_button_title".localized, style: .plain, target: self, action: #selector(notImplementedPopup))
        navigationItem.rightBarButtonItem = filtersButton
        navigationItem.rightBarButtonItem?.tintColor = .black
        
        self.title = "browse_brands_title".localized
    }
    
    func configureUI() {
        searchTextField.placeholder = "search".localized
        
        searchTextField.leftViewMode = .always
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: searchTextField.frame.height, height: searchTextField.frame.height))

        let imageView = UIImageView(frame: CGRect(x: iconView.frame.height / 3, y: iconView.frame.height / 4, width: searchTextField.frame.height / 2, height: searchTextField.frame.height / 2))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "search")
        
        iconView.addSubview(imageView)
        
        searchTextField.leftView = iconView
    }
    
    @objc func notImplementedPopup() {
        let alert = UIAlertController(title: "Feature not implemented", message: nil, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true, completion: nil)
    }
}

extension BrowseBrandsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0:
                return viewModel.getMembershipPlans().count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BrandTableViewCell", for: indexPath) as? BrandTableViewCell else { return UITableViewCell() }
        
        let membershipPlan = viewModel.getMembershipPlans()[indexPath.row]
        
        if let brandName = membershipPlan.account?.companyName, let imageUrl = membershipPlan.images?.first(where: {$0.type == 3})?.url {
            switch indexPath.section {
            case 0:
                cell.configure(imageURL: imageUrl, brandName: brandName, description: true)
                if indexPath.row == viewModel.getMembershipPlans().count - 1 {
                    cell.hideSeparatorView()
                }
                break
            case 1:
                cell.configure(imageURL: "", brandName: brandName)
                if indexPath.row == viewModel.getMembershipPlans().count - 1 {
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
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 47))
        titleLabel.font = UIFont.headline
        if section == 0 {
            titleLabel.text = "pll_title".localized
        } else if section == 1 {
            titleLabel.text = "all_title".localized
        }
        view.addSubview(titleLabel)
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 47
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBrand = viewModel.getMembershipPlans()[indexPath.row]
        viewModel.toAddOrJoinScreen(membershipPlan: selectedBrand)
    }
}
