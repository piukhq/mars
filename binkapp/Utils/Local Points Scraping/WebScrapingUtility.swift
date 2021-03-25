//
//  WebScrapingUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit

struct WebScrapingCredentials {
    let username: String
    let password: String
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
}

class WebScrapingUtility: NSObject {
    var isRunning = false
    
    private let webView: WKWebView
    private var agent: WebScrapable?
    private var membershipCard: CD_MembershipCard?

    private weak var delegate: WebScrapingUtilityDelegate?

    private var idleTimer: Timer?
    private var detectElementTimer: Timer?
    private let idleThreshold: TimeInterval = 60

    private var hasAttemptedLogin = false
    private var isPerformingUserAction = false
    private var isReloadingWebView = false

    private var isInDebugMode: Bool {
        return Current.pointsScrapingManager.isDebugMode
    }

    private var isPresentingWebView: Bool {
        guard let navigationViewController = UIViewController.topMostViewController() as? UINavigationController else { return false }
        guard let topViewController = navigationViewController.viewControllers.first else { return false }
        return topViewController.view.subviews.contains(webView)
    }

    private var isBalanceRefresh: Bool {
        guard let balances = membershipCard?.formattedBalances, !balances.isEmpty else { return false }
        return true
    }
    
    init(delegate: WebScrapingUtilityDelegate?) {
        webView = WKWebView(frame: .zero)
        self.delegate = delegate
        super.init()
    }
    
    func start(agent: WebScrapable, membershipCard: CD_MembershipCard) throws {
        self.agent = agent
        self.membershipCard = membershipCard
        
        let urlString = isBalanceRefresh ? agent.scrapableUrlString : agent.loginUrlString
        
        guard let url = URL(string: urlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        
        if isInDebugMode {
            presentWebView()
        }
        
        let request = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(request)

        resetIdlingTimer()
    }
    
    private func stop() {
        agent = nil
        membershipCard = nil
        hasAttemptedLogin = false
        idleTimer?.invalidate()
        detectElementTimer?.invalidate()
    }

    private func resetIdlingTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleThreshold, repeats: false, block: { timer in
            // The webview has sat idle for a period of time without performing any navigation.
            // If we don't force to failed, the card will remain in an unusable pending state.
            timer.invalidate()
            self.finish(withError: .unhandledIdling)
        })
    }

    private func presentWebView() {
        guard !isPresentingWebView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let viewController = WebScrapingViewController(webView: self.webView, delegate: self)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }

    private func closeWebView(force: Bool = false) {
        if !force, isInDebugMode { return }
        if isPresentingWebView {
            Current.navigate.close()
        }
    }

    private func login(credentials: WebScrapingCredentials) {
        guard let agent = agent, let script = script(scriptName: agent.loginScriptFileName) else {
            self.finish(withError: .loginScriptFileNotFound)
            return
        }
        let formattedScript = String(format: script, credentials.username, credentials.password)

        runScript(formattedScript) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                // Successfully executed login script, but didn't necessarily succeed
                // We may have encountered an error, or recaptcha
                if let error = response.errorMessage {
                    self.finish(withError: .loginFailed(errorMessage: error))
                    return
                }

                if response.userActionRequired == true {
                    self.idleTimer?.invalidate()
                    self.isPerformingUserAction = true
                    self.presentWebView()
                    self.detectElementTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectRecaptchaSuccess), userInfo: nil, repeats: true)
                    return
                }
                
                if Current.pointsScrapingManager.isDebugMode {
                    DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - Logged in", type: .success)
                }
            case .failure:
                self.finish(withError: .failedToExecuteLoginScript)
            }
        }
    }

    @objc private func detectRecaptchaSuccess() {
        guard let card = membershipCard else { return }
        
        detectElement(queryString: "re-captcha[class*=-valid]") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if response.elementDetected == true {
                    self.resetIdlingTimer()
                    self.detectElementTimer?.invalidate()
                    self.isPerformingUserAction = false
                    self.closeWebView()

                    guard let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: card.id) else {
                        self.finish(withError: .failedToExecuteLoginScript)
                        return
                    }
                    self.login(credentials: credentials)
                }
            case .failure:
                self.finish(withError: .loginFailed(errorMessage: "Failed to detect recaptcha element."))
            }
        }
    }

    private func getScrapedValue(completion: @escaping (Result<Int, WebScrapingUtilityError>) -> Void) {
        guard let agent = agent, let script = script(scriptName: agent.pointsScrapingScriptFileName) else {
            completion(.failure(.scapingScriptFileNotFound))
            return
        }

        runScript(script) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                if let error = response.errorMessage {
                    self.finish(withError: .pointsScrapingFailed(errorMessage: error))
                    return
                }

                guard let points = response.pointsValue else {
                    self.finish(withError: .failedToCastReturnValue)
                    return
                }
                completion(.success(points))
            case .failure:
                self.finish(withError: .failedToExecuteScrapingScript)
            }
        }
    }

    private func detectElement(queryString: String, completion: @escaping (Result<WebScrapingResponse, WebScrapingUtilityError>) -> Void) {
        guard let script = script(scriptName: "LocalPointsCollection_DetectElement") else {
            return
        }
        let formattedScript = String(format: script, queryString)
        runScript(formattedScript, completion: completion)
    }

    private func script(scriptName: String) -> String? {
        guard let file = Bundle.main.url(forResource: scriptName, withExtension: "js") else {
            return nil
        }
        return try? String(contentsOf: file)
    }

    private func runScript(_ script: String, completion: @escaping (Result<WebScrapingResponse, WebScrapingUtilityError>) -> Void) {
        if isRunning { return }
        isRunning = true
        webView.evaluateJavaScript(script) { [weak self] (response, error) in
            self?.isRunning = false
            guard error == nil else {
                completion(.failure(.javascriptError))
                return
            }
            
            guard let response = response else {
                completion(.failure(.javascriptError))
                return
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                let scrapingResponse = try JSONDecoder().decode(WebScrapingResponse.self, from: data)
                completion(.success(scrapingResponse))
            } catch {
                completion(.failure(.javascriptError))
            }
        }
    }

    private func finish(withValue value: Int? = nil, withError error: WebScrapingUtilityError? = nil) {
        defer {
            stop()
        }
        
        guard let agent = agent else { return }
        guard let membershipCard = membershipCard else { return }

        if let value = value {
            if Current.pointsScrapingManager.isDebugMode {
                DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - Retreived points balance", type: .success)
            }
            delegate?.webScrapingUtility(self, didCompleteWithValue: value, forMembershipCard: membershipCard, withAgent: agent)
        }

        if let error = error {
            if Current.pointsScrapingManager.isDebugMode {
                DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - \(error.localizedDescription)", type: .failure)
            }
            SentryService.triggerException(.localPointsCollectionFailed(error, agent.merchant, balanceRefresh: isBalanceRefresh))
            delegate?.webScrapingUtility(self, didCompleteWithError: error, forMembershipCard: membershipCard, withAgent: agent)
        }
    }
    
    private var shouldScrape: Bool {
        return isLikelyAtScrapableScreen
    }
    
    private var shouldAttemptLogin: Bool {
        return isLikelyAtLoginScreen && !hasAttemptedLogin
    }
    
    private var isRedirecting: Bool {
        return !isLikelyAtLoginScreen && !isLikelyAtScrapableScreen
    }
    
    private var isLikelyAtLoginScreen: Bool {
        guard let urlString = agent?.loginUrlString else { return false }
        return webView.url?.absoluteString.starts(with: urlString) == true
    }
    
    private var isLikelyAtScrapableScreen: Bool {
        guard let agent = agent else { return false }
        guard agent.loginUrlString != agent.scrapableUrlString else {
            // This agent has the same url for login and scraping
            // If we have attempted login, we may be able to scrape here
            return hasAttemptedLogin
        }
        return webView.url?.absoluteString.starts(with: agent.scrapableUrlString) == true
    }

    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return membershipCard?.id == card.id
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        handleWebViewNavigation()

        // We know that if we entered this delegate method via a forced reload, we've now completed that
        isReloadingWebView = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        decisionHandler(.allow, preferences)

        if webView.url?.absoluteString.contains("#") == true, !isReloadingWebView, shouldScrape {
            isReloadingWebView = true
            webView.reload()
        }
    }

    private func handleWebViewNavigation() {
        resetIdlingTimer()

        // We only care about the webview navigation to our agent's login url or scrapable url
        guard !isRedirecting else { return }

        if shouldScrape {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.getScrapedValue { [weak self] result in
                    guard let self = self else { return }

                    switch result {
                    case .failure(let error):
                        self.finish(withError: error)
                    case .success(let pointsValue):
                        self.finish(withValue: pointsValue)
                    }
                }
            }
        } else {
            do {
                guard let id = membershipCard?.id else {
                    self.finish(withError: .loginFailed(errorMessage: nil))
                    return
                }
                let credentials = try Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: id)
                if shouldAttemptLogin {
                    hasAttemptedLogin = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        self.login(credentials: credentials)
                    }
                } else {
                    // We should only fall into here if we know we are at the login url, but we've already attempted a login
                    self.finish(withError: .loginFailed(errorMessage: nil))
                }
            } catch {
                if let webScrapingError = error as? WebScrapingUtilityError {
                    self.finish(withError: webScrapingError)
                } else {
                    self.finish(withError: .loginFailed(errorMessage: nil))
                }
            }
        }
    }
    
    func debug() {
        presentWebView()
    }
}

extension WebScrapingUtility: WebScrapingViewControllerDelegate {
    func webScrapingViewControllerDidDismiss(_ viewController: WebScrapingViewController) {
        if isInDebugMode {
            resetIdlingTimer()
            return
        }
        if isPerformingUserAction {
            self.finish(withError: .userDismissedWebView)
        }
    }
}
