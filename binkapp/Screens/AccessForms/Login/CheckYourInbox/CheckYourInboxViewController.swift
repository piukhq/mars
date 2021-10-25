//
//  CheckYourInboxViewController.swift
//  binkapp
//
//  Created by Sean Williams on 25/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit

class CheckYourInboxViewController: BinkViewController {
    private lazy var stackScrollView: StackScrollView = {
        let stackView = StackScrollView(axis: .vertical, arrangedSubviews: [textView], adjustForKeyboard: true)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .clear
        stackView.margin = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        stackView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        stackView.distribution = .fill
        stackView.alignment = .fill
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        return textView
    }()
    
    private lazy var primaryButton: BinkButton = {
        return BinkButton(type: .gradient, title: "", enabled: true, action: {
            
        })
    }()
    
    private var viewModel: CheckYourInboxViewModel
    
    init(viewModel: CheckYourInboxViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        footerButtons.append(primaryButton)
        configureUI()
    }

    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        textView.textColor = Current.themeManager.color(for: .text)
    }
    
    private func configureUI() {
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 140, right: 0)
        textView.attributedText = viewModel.text
        textView.linkTextAttributes = [.foregroundColor: UIColor.blueAccent, .underlineStyle: NSUnderlineStyle.single.rawValue]
        
        NSLayoutConstraint.activate([
            stackScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            stackScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            stackScrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            stackScrollView.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
}
