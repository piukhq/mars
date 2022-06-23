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
    
    private(set) weak var tableView: UITableView?
    weak var delegate: OptionItemListViewControllerDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        modalPresentationStyle = .popover
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UITableView(frame: .zero, style: UITableView.Style.plain)
        tableView = view as? UITableView
        tableView?.isScrollEnabled = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.dataSource = self
        tableView?.delegate = self
        tableView?.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func calculateAndSetPreferredContentSize() {
        let totalItems = CGFloat(items.flatMap { $0 }.count)
        let totalHeight = totalItems * 64
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
    var font = UIFont.systemFont(ofSize: 13)
    var isSelected: Bool
    var orderType: SortState
}
