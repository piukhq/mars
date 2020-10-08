//
//  WhoWeAreViewController.swift
//  binkapp
//
//  Created by Sean Williams on 07/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class WhoWeAreViewController: UIViewController {

    
    // MARK: - UI Lazy Variables

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = LayoutHelper.WhoWeAre.stackScrollViewMargins
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.delegate = self
        stackView.contentInset = LayoutHelper.WhoWeAre.stackScrollViewContentInsets
        return stackView
    }()
    
    private lazy var binkLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "bink-icon-logo")
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    private lazy var textStackView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.contentInset = LayoutHelper.WhoWeAre.textStackScrollViewContentInsets
        stackView.isScrollEnabled = false
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.text = "who_we_are_title".localized
        label.font = UIFont.headline
        return label
    }()
    
    private lazy var descriptionText: UILabel = {
       let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.text = "who_we_are_body".localized
        label.font = UIFont.bodyTextLarge
        label.numberOfLines = 0
        return label
    }()

    private lazy var binkPeopleTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorColor = .lightGray
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BinkPersonTableViewCell.self, asNib: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = LayoutHelper.WhoWeAre.tableViewSeperatorInsets
        tableView.rowHeight = 80
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let viewModel: WhoWeAreViewModel
    
    init(viewModel: WhoWeAreViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
}

// MARK: - Tableview Delegates

extension WhoWeAreViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.teamMembers.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BinkPersonTableViewCell = binkPeopleTableView.dequeue(indexPath: indexPath)
        cell.configure(with: viewModel.teamMembers[indexPath.row])
        
        if tableView.cellAtIndexPathIsLastInSection(indexPath) {
            cell.hideSeparator()
        }
        
        return cell
    }
    
 
}


// MARK: - Private Methods

private extension WhoWeAreViewController {
    func configureUI() {
        
        view.addSubview(stackScrollView)
        stackScrollView.add(arrangedSubview: binkLogo)
        textStackView.add(arrangedSubview: titleLabel)
        textStackView.add(arrangedSubview: descriptionText)
        stackScrollView.add(arrangedSubview: textStackView)
        stackScrollView.add(arrangedSubview: binkPeopleTableView)
        configureLayout()

    }
    
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),
            binkLogo.heightAnchor.constraint(equalToConstant: 142),
            binkLogo.widthAnchor.constraint(equalToConstant: 142),
            textStackView.heightAnchor.constraint(equalToConstant: 175),
            binkPeopleTableView.heightAnchor.constraint(equalToConstant: 1000),
            binkPeopleTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor)
        ])
    }
    
}

extension LayoutHelper {
    struct WhoWeAre {
        static let stackScrollViewMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 25)
        static let stackScrollViewContentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        static let textStackScrollViewContentInsets = UIEdgeInsets(top: 50, left: 0, bottom: 50, right: 0)
        static let tableViewSeperatorInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)

    }
}
