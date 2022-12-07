//
//  OptionItemListViewController.swift
//  binkapp
//
//  Created by Ricardo Silva on 23/06/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import UIKit
protocol OptionItemListViewControllerTestable {
    func getTableView() -> UITableView
}

protocol OptionItemProtocol {
    var text: String { get }
    var isSelected: Bool { get set }
}

extension UITableViewCell {
    func configure(with optionItem: OptionItemProtocol) {
        textLabel?.text = optionItem.text
        textLabel?.font = UIFont.walletPromptTitleSmall
        tintColor = Current.themeManager.color(for: .text)
        backgroundColor = Current.themeManager.color(for: .walletCardBackground)
    }
}

protocol OptionItemListViewControllerDelegate: AnyObject {
    func optionItemListViewController(_ controller: OptionItemListViewController, didSelectOptionItem item: OptionItemProtocol)
}

class OptionItemListViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .tabBar
        label.text = self.title
        return label
    }()
    
    private lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = Current.themeManager.color(for: .text)
        line.alpha = 0.3
        return line
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        table.isScrollEnabled = false
        return table
    }()
    
    var items: [OptionItemProtocol] = [] {
        didSet {
            calculateAndSetPreferredContentSize()
        }
    }
    
    weak var delegate: OptionItemListViewControllerDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .popover
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func loadView() {
        super.loadView()

        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: LayoutHelper.SortOrderLayout.titleLabelTopOffset).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: LayoutHelper.SortOrderLayout.titleLabelHorizontalOffset).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -LayoutHelper.SortOrderLayout.titleLabelHorizontalOffset).isActive = true
        
        view.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: LayoutHelper.SortOrderLayout.lineSeparatorTopOffset).isActive = true
        lineView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        lineView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: LayoutHelper.SortOrderLayout.lineSeparatorHeight).isActive = true
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: LayoutHelper.SortOrderLayout.lineSeparatorHeight).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        view.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func calculateAndSetPreferredContentSize() {
        let totalItems = CGFloat(items.count)
        let totalHeight = totalItems * 80
        preferredContentSize = CGSize(width: CGFloat(200), height: totalHeight)
    }
}

extension OptionItemListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LayoutHelper.SortOrderLayout.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let item = items[indexPath.row]
        cell.configure(with: item)
        
        cell.accessoryType = item.isSelected ? .checkmark : .none
        
        return cell
    }
}

extension OptionItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = items[indexPath.row]
        item.isSelected = true
        delegate?.optionItemListViewController(self, didSelectOptionItem: item)
    }
}

struct SortOrderOptionItem: OptionItemProtocol {
    var text: String {
        return orderType.rawValue
    }
    var isSelected: Bool
    var orderType: MembershipCardsSortState
}

extension OptionItemListViewController: OptionItemListViewControllerTestable {
    func getTableView() -> UITableView {
        return tableView
    }
}
