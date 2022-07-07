//
//  OptionItemListViewController.swift
//  binkapp
//
//  Created by Ricardo Silva on 23/06/2022.
//  Copyright © 2022 Bink. All rights reserved.
//

import UIKit

protocol OptionItem {
    var text: String { get }
    var isSelected: Bool { get set }
    var font: UIFont { get set }
}

extension UITableViewCell {
    func configure(with optionItem: OptionItem) {
        textLabel?.text = optionItem.text
        textLabel?.font = optionItem.font
        tintColor = Current.themeManager.color(for: .text)
        backgroundColor = Current.themeManager.color(for: .walletCardBackground)
    }
}

extension OptionItem {
    func sizeForDisplayText() -> CGSize {
        return text.size(withAttributes: [NSAttributedString.Key.font: font])
    }
}

protocol OptionItemListViewControllerDelegate: AnyObject {
    func optionItemListViewController(_ controller: OptionItemListViewController, didSelectOptionItem item: OptionItem)
}

class OptionItemListViewController: UIViewController {
    var items = [[OptionItem]]() {
        didSet {
            calculateAndSetPreferredContentSize()
        }
    }
    var tableView = UITableView()
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

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .tabBar
        label.text = self.title

        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 34).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -34).isActive = true
        
        let line = UIView()
        line.backgroundColor = Current.themeManager.color(for: .text)
        line.alpha = 0.3
        view.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 4).isActive = true
        line.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        line.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: line.bottomAnchor, constant: 1).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
        
        view.backgroundColor = Current.themeManager.color(for: .walletCardBackground)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func calculateAndSetPreferredContentSize() {
        let totalItems = CGFloat(items.flatMap { $0 }.count)
        let totalHeight = totalItems * 80
        preferredContentSize = CGSize(width: CGFloat(200), height: totalHeight)
    }
}

extension OptionItemListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items[section].count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let item = items[indexPath.section][indexPath.row]
        cell.configure(with: item)
        
        if item.isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

extension OptionItemListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var item = items[indexPath.section][indexPath.row]
        item.isSelected = true
        delegate?.optionItemListViewController(self, didSelectOptionItem: item)
    }
}

struct SortOrderOptionItem: OptionItem {
    var text: String
    var font = UIFont.walletPromptTitleSmall
    var isSelected: Bool
    var orderType: MembershipCardsSortState
}
