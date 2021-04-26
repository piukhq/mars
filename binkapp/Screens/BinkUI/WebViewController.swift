//
//  WebViewController.swift
//  binkapp
//
//  Created by Paul Tiriteu on 27/04/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: BinkViewController {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setWebView()
        setBottomToolbar()
        
        guard let safeUrl = url else { return }
        let request = URLRequest(url: safeUrl)
        webView.load(request)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setActivityIndicator()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Use the toolbar height to make sure webview is inset correctly
        var currentEdgeInsets = webView.scrollView.contentInset
        currentEdgeInsets.bottom = navigationController?.toolbar.frame.size.height ?? 0
        webView.scrollView.contentInset = currentEdgeInsets
    }
    
    override func configureForCurrentTheme() {
        super.configureForCurrentTheme()
        navigationController?.toolbar.tintColor = Current.themeManager.color(for: .text)
    }
    
    private func setWebView() {
        webView = WKWebView(frame: view.frame)
        webView.navigationDelegate = self

        view.addSubview(webView)
    }
    
    private func setActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: webView.frame.width, height: webView.frame.height))
        activityIndicator.style = .large
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
    
    private func setBottomToolbar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
                
        let backImage = UIImage(named: "forward")?.withHorizontallyFlippedOrientation()
        let forwardImage = UIImage(named: "forward")
        
        backButton = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goBack))
        forwardButton = UIBarButtonItem(image: forwardImage, style: .plain, target: self, action: #selector(goForward))
        
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        
        let refreshButton = UIBarButtonItem(image: UIImage(named: "refresh"), style: .plain, target: self, action: #selector(refresh))
        
        navigationController?.setToolbarHidden(false, animated: true)
        setToolbarItems([refreshButton, flexibleSpace, flexibleSpace, flexibleSpace, flexibleSpace, backButton, flexibleSpace, forwardButton], animated: true)
    }
    
    private func checkToolbarItemsState() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    private func showErrorAlert() {
        let alert = ViewControllerFactory.makeOkAlertViewController(title: L10n.errorTitle, message: L10n.loadingError)
        Current.navigate.to(AlertNavigationRequest(alertController: alert))
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
}

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
        showErrorAlert()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        showActivityIndicator(show: false)
        showErrorAlert()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .linkActivated {
            // Pull email url from the navigation request if we can
            guard let emailUrl = navigationAction.request.url, emailUrl.isEmailAddressLink else {
                // Either we can't parse the url correctly, or it is not an email address link. Either way, continue navigation if we can.
                decisionHandler(.allow)
                return
            }
            // Open the mail app with the email address link, and stop any webview navigation
            UIApplication.shared.open(emailUrl, options: [:], completionHandler: nil)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

extension URL {
    var isEmailAddressLink: Bool {
        return absoluteString.starts(with: "mailto")
    }
}
