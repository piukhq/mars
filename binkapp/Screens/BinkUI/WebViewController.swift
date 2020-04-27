//
//  WebViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 27/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import SafariServices

class WebViewController: UIViewController {
    private let url: URL?
    
    init(urlString: String) {
        self.url = URL(string: urlString)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let safeUrl = url else { return }
        let configuration = SFSafariViewController.Configuration()
        let viewController = SFSafariViewController(url: safeUrl, configuration: configuration)
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
//    fileprivate func setToolBar() {
//        let screenWidth = self.view.bounds.width
//        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(goBack))
//        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 44))
//        toolBar.isTranslucent = false
//        toolBar.translatesAutoresizingMaskIntoConstraints = false
//        toolBar.items = [backButton]
//        webView.addSubview(toolBar)
//
//        NSLayoutConstraint.activate([
//            toolBar.topAnchor.constraint(equalTo: webView.topAnchor),
//            toolBar.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
//            toolBar.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
//        ])
//    }
//
//    @objc private func goBack() {
//        if webView.canGoBack {
//            webView.goBack()
//        } else {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }
}

extension WebViewController: SFSafariViewControllerDelegate {
    
}
