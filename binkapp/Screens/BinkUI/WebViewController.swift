//
//  WebViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 27/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit

private struct Constants {
    static let toolbarHeight: CGFloat = 44
}

class WebViewController: UIViewController {
    private let url: URL?
    private var webView: WKWebView!
    private var activityIndicator: UIActivityIndicatorView!
    
    private var backButton: UIBarButtonItem!
    private var forwardButton: UIBarButtonItem!
    
    init(urlString: String) {
        self.url = URL(string: urlString)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTopToolbar()
        setBottomToolbar()
        
        guard let safeUrl = url else { return }
        let request = URLRequest(url: safeUrl)
        webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setActivityIndicator()
    }
    
    private func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: webView.frame.width, height: webView.frame.height))
        if #available(iOS 13.0, *) {
            activityIndicator.style = .large
        } else {
            activityIndicator.style = .gray
        }
        activityIndicator.hidesWhenStopped = true
        webView.addSubview(activityIndicator)
    }
    
    private func showActivityIndicator(show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    private func setTopToolbar() {
        let screenWidth = self.view.bounds.width
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let closeButton = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(dismissWebView))
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: Constants.toolbarHeight))
        toolBar.isTranslucent = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.items = [flexibleSpace, closeButton]
        webView.addSubview(toolBar)
        
        NSLayoutConstraint.activate([
            toolBar.topAnchor.constraint(equalTo: webView.topAnchor, constant: 0),
            toolBar.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 0),
            toolBar.trailingAnchor.constraint(equalTo: webView.trailingAnchor, constant: 0)
        ])
    }
    
    private func setBottomToolbar() {
        let screenWidth = self.view.bounds.width
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        let backImage = UIImage(named: "forward")?.withHorizontallyFlippedOrientation()
        let forwardImage = UIImage(named: "forward")
        
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goBack))
        forwardButton = UIBarButtonItem(image: forwardImage, style: .plain, target: self, action: #selector(goForward))
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
        let refreshButton = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(refresh))
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: Constants.toolbarHeight))
        toolBar.isTranslucent = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        toolBar.items = [refreshButton, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, backButton, flexibleSpace, forwardButton]
        webView.addSubview(toolBar)
        
        NSLayoutConstraint.activate([
            toolBar.bottomAnchor.constraint(equalTo: webView.bottomAnchor, constant: 0),
            toolBar.leadingAnchor.constraint(equalTo: webView.leadingAnchor, constant: 0),
            toolBar.trailingAnchor.constraint(equalTo: webView.trailingAnchor, constant: 0)
        ])
    }
    
    private func checkToolbarItemsState() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    @objc private func refresh() {
        webView.reload()
    }

    @objc private func dismissWebView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension WebViewController: WKUIDelegate {}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        checkToolbarItemsState()
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        showActivityIndicator(show: true)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        showActivityIndicator(show: false)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
    }
}
