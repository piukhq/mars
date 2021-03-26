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
    
    private let primaryWebview: WKWebView
    private var activeWebview: WKWebView!
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
        return topViewController.view.subviews.contains(activeWebview)
    }

    private var isBalanceRefresh: Bool {
        guard let balances = membershipCard?.formattedBalances, !balances.isEmpty else { return false }
        return true
    }
    
    init(delegate: WebScrapingUtilityDelegate?) {
        primaryWebview = WKWebView(frame: .zero)
        self.delegate = delegate
        super.init()
    }
    
    func start(agent: WebScrapable, membershipCard: CD_MembershipCard) throws {
        self.agent = agent
        self.membershipCard = membershipCard
        
        guard let url = URL(string: agent.scrapableUrlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        
        if isInDebugMode {
            presentWebView()
        }
        
        let request = URLRequest(url: url)
        
        activeWebview = appropriateWebview()
        
        activeWebview.navigationDelegate = self
        activeWebview.load(request)

        resetIdlingTimer()
    }
    
    private func appropriateWebview() -> WKWebView {
        // TODO: The first card for each plan added should always use the primary webview for best user experience. If we add another one, it should use a new temporary webview, but if the first one refreshes it's balance, it should use the primary webview
        
        // Is this card the only card of it's type in the wallet?
        
        // Should we maintain an array of primary scraping cards, and everything else uses a temporary webview?
        
        // First card of each type added to the array
        
        
        
        
        
        
        
        
        let scrapedMembershipCards = Current.wallet.membershipCards?.filter {
            if let planIdString = $0.membershipPlan?.id, let planId = Int(planIdString) {
                 return Current.pointsScrapingManager.planIdIsWebScrapable(planId)
            }
            return false
        }.compactMap { $0 }
        
        guard let cards = scrapedMembershipCards else { return primaryWebview }
        
        let scrapedPlans = cards.map { $0.membershipPlan }.compactMap { $0 }
        
        if let plan = membershipCard?.membershipPlan, scrapedPlans.contains(plan) {
            return WKWebView(frame: .zero)
        } else {
            return primaryWebview
        }
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
        guard let activeWebview = activeWebview else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let viewController = WebScrapingViewController(webView: activeWebview, delegate: self)
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

    @objc private func detectRecaptchaSuccess() {
//        guard let card = membershipCard else { return }
//
//        detectElement(queryString: "re-captcha[class*=-valid]") { [weak self] result in
//            guard let self = self else { return }
//            switch result {
//            case .success(let response):
//                if response.elementDetected == true {
//                    self.resetIdlingTimer()
//                    self.detectElementTimer?.invalidate()
//                    self.isPerformingUserAction = false
//                    self.closeWebView()
//
//                    guard let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: card.id) else {
//                        self.finish(withError: .failedToExecuteLoginScript)
//                        return
//                    }
//                    self.login(credentials: credentials)
//                }
//            case .failure:
//                self.finish(withError: .loginFailed(errorMessage: "Failed to detect recaptcha element."))
//            }
//        }
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
        activeWebview.evaluateJavaScript(script) { [weak self] (response, error) in
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

    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return membershipCard?.id == card.id
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // We know that if we entered this delegate method via a forced reload, we've now completed that
        isReloadingWebView = false
        handleWebViewNavigation()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        decisionHandler(.allow, preferences)

        if webView.url?.absoluteString.contains("#") == true, !isReloadingWebView {
            isReloadingWebView = true
            webView.reload()
        }
    }

    private func handleWebViewNavigation() {
        resetIdlingTimer()
        
        if let navigateScript = script(scriptName: "LocalPointsCollection_Navigate_Template") {
            // TODO: Inject credentials
            let formattedScript = String(format: navigateScript, "", "")
            runScript(formattedScript) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let error = response.errorMessage {
                        self.finish(withError: .pointsScrapingFailed(errorMessage: error))
                        return
                    }
                    
                    if response.didAttemptLogin == true, Current.pointsScrapingManager.isDebugMode, let agent = self.agent {
                        DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - Attempted to log in", type: .success)
                    }

                    if let points = response.pointsValue {
                        self.finish(withValue: points)
                        return
                    }
                case .failure(let error):
                    self.finish(withError: error)
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
