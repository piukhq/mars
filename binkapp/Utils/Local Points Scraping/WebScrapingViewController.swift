//
//  WebScrapingViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 03/02/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import UIKit
import WebKit

protocol WebScrapingViewControllerDelegate: AnyObject {
    func webScrapingViewControllerDidDismiss(_ viewController: WebScrapingViewController)
}

class WebScrapingViewController: BinkViewController {
    private let webView: WKWebView
    private weak var delegate: WebScrapingViewControllerDelegate?

    init(webView: WKWebView, delegate: WebScrapingViewControllerDelegate?) {
        self.webView = webView
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame = view.frame
        view.addSubview(webView)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.webScrapingViewControllerDidDismiss(self)
    }
}
