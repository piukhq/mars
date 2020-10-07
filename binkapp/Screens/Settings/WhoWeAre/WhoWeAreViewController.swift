//
//  WhoWeAreViewController.swift
//  binkapp
//
//  Created by Sean Williams on 07/10/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit

class WhoWeAreViewController: UIViewController, UIScrollViewDelegate {

    
    // MARK: - UI Lazy Variables

    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: nil, adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .white
        stackView.margin = LayoutHelper.PaymentCardDetail.stackScrollViewMargins
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.delegate = self
        stackView.contentInset = LayoutHelper.PaymentCardDetail.stackScrollViewContentInsets
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
}

private extension WhoWeAreViewController {
    func configureUI() {
        
        view.addSubview(stackScrollView)
        stackScrollView.add(arrangedSubview: titleLabel)
        stackScrollView.add(arrangedSubview: descriptionText)
        
        configureLayout()
    }
    
    
    func configureLayout() {
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor),

        ])
    }
    
}
