//
//  WhoWeAreViewController.swift
//  binkapp
//
//  Created by Sean Williams on 07/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit


struct BinkTeamMember {
    let name: String
}

class WhoWeAreViewController: BinkViewController {
    // MARK: - UI Lazy Variables
    
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.margin = LayoutHelper.WhoWeAre.stackScrollMargin
        stackView.delegate = self
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
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.backgroundColor = .clear
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
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.text = "who_we_are_body".localized
        label.font = UIFont.bodyTextLarge
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var binkPeopleTableView: NestedTableView = {
        let tableView = NestedTableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(BinkPersonTableViewCell.self, asNib: true)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = LayoutHelper.WhoWeAre.tableViewSeperatorInsets
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    let teamMembers: [BinkTeamMember] = [
        BinkTeamMember(name: "Paul Batty"),
        BinkTeamMember(name: "Nick Farrant"),
        BinkTeamMember(name: "Susanne King"),
        BinkTeamMember(name: "Srikalyani Kotha"),
        BinkTeamMember(name: "Marius Lobontiu"),
        BinkTeamMember(name: "Carmen Muntean"),
        BinkTeamMember(name: "Dorin Pop"),
        BinkTeamMember(name: "Karl Sigiscar"),
        BinkTeamMember(name: "Paul Tiritieu"),
        BinkTeamMember(name: "Sean Williams"),
        BinkTeamMember(name: "Max Woodhams")
    ]
    
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        titleLabel.textColor = Current.themeManager.color(for: .text)
        descriptionLabel.textColor = Current.themeManager.color(for: .text)
        binkPeopleTableView.separatorColor = Current.themeManager.color(for: .divider)
        binkPeopleTableView.reloadData()
    }
}

// MARK: - Tableview

extension WhoWeAreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BinkPersonTableViewCell = binkPeopleTableView.dequeue(indexPath: indexPath)
        cell.configure(with: teamMembers[indexPath.row])
        
        if tableView.cellAtIndexPathIsLastInSection(indexPath) {
            cell.hideSeparator()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}


// MARK: - Private Methods

private extension WhoWeAreViewController {
    func configureUI() {
        view.addSubview(stackScrollView)
        stackScrollView.add(arrangedSubview: binkLogo)
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
            binkLogo.heightAnchor.constraint(equalToConstant: LayoutHelper.WhoWeAre.logoDimension),
            binkLogo.widthAnchor.constraint(equalToConstant: LayoutHelper.WhoWeAre.logoDimension),
            textStackView.leftAnchor.constraint(equalTo: stackScrollView.leftAnchor, constant: LayoutHelper.WhoWeAre.textStackViewPadding),
            textStackView.rightAnchor.constraint(equalTo: stackScrollView.rightAnchor, constant: -LayoutHelper.WhoWeAre.textStackViewPadding),
            binkPeopleTableView.widthAnchor.constraint(equalTo: stackScrollView.widthAnchor)
        ])
        
        stackScrollView.customPadding(LayoutHelper.WhoWeAre.stackScrollViewBottomPadding, before: binkPeopleTableView)
        stackScrollView.customPadding(LayoutHelper.WhoWeAre.stackScrollViewTopPadding, before: textStackView)
    }
}

extension LayoutHelper {
    enum WhoWeAre {
        static let stackScrollMargin = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        static let tableViewSeperatorInsets = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        static let logoDimension: CGFloat = 142
        static let textStackViewPadding: CGFloat = 25
        static let stackScrollViewTopPadding: CGFloat = 40
        static let stackScrollViewBottomPadding: CGFloat = 10
    }
}
