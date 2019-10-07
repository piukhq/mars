//
//  PendingViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class SimpleInfoViewController: UIViewController {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    private let viewModel: SimpleInfoViewModel
    
    init(viewModel: SimpleInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "SimpleInfoViewController", bundle: Bundle(for: SimpleInfoViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack"), style: .plain, target: self, action: #selector(popViewController))
        
        titleLabel.text = viewModel.title
        descriptionLabel.text = viewModel.description
        titleLabel.font = .headline
        descriptionLabel.font = .bodyTextLarge
    }
    
    @objc private func popViewController() {
        viewModel.popViewController()
    }
}
