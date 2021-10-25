//
//  CheckYourInboxViewController.swift
//  binkapp
//
//  Created by Sean Williams on 25/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class CheckYourInboxViewController: BinkViewController {

    lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [textView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.customPadding(20, after: brandHeaderView)
        view.addSubview(stackView)
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
