//
//  PendingViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 16/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit

class PendingViewController: UIViewController {
    private let viewModel: PendingViewModel
    
    init(viewModel: PendingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: "PendingViewController", bundle: Bundle(for: PendingViewController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "navbarIconsBack")?.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(popViewController))
    }
    
    @objc private func popViewController() {
        router.popViewController()
    }
}
