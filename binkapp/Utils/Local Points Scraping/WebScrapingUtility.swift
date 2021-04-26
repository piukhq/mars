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

struct PriorityScrapableCard {
    let cardId: String
    let planId: String
    
    init?(membershipCard: CD_MembershipCard) {
        self.cardId = membershipCard.id
        guard let planId = membershipCard.membershipPlan?.id else { return nil }
        self.planId = planId
    }
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
}

class WebScrapingUtility: NSObject {
    var isExecutingScript = false
    var isRunning: Bool {
        return membershipCard != nil || agent != nil
    }
    
    private let priorityWebview: WKWebView
    private var activeWebview: WKWebView?
    private var priorityScrapableCards: [PriorityScrapableCard] = []
    
    private var agent: WebScrapable?
    private var membershipCard: CD_MembershipCard?

    private weak var delegate: WebScrapingUtilityDelegate?

    private var idleTimer: Timer?
    private let idleThreshold: TimeInterval = 20
    private let idleRetryLimit = 2
    private var idleRetryCount = 0
    
    private var userActionTimer: Timer?

    private var isPerformingUserAction = false

    private var isInDebugMode: Bool {
        return Current.pointsScrapingManager.isDebugMode
    }

    private var isPresentingWebView: Bool {
        guard let activeWebview = activeWebview else { return false }
        guard let navigationViewController = UIViewController.topMostViewController() as? UINavigationController else { return false }
        guard let topViewController = navigationViewController.viewControllers.first else { return false }
        return topViewController.view.subviews.contains(activeWebview)
    }

    private var isBalanceRefresh: Bool {
        guard let balances = membershipCard?.formattedBalances, !balances.isEmpty else { return false }
        return true
    }
    
    init(delegate: WebScrapingUtilityDelegate?) {
        priorityWebview = WKWebView(frame: .zero)
        self.delegate = delegate
        super.init()
    }
    
    func start(agent: WebScrapable, membershipCard: CD_MembershipCard) throws {
        /// If we have a membership card or agent, then we are currently in the process of scraping and should not be interrupted
        guard !isRunning else { return }
        
        self.agent = agent
        self.membershipCard = membershipCard
        
        guard let url = URL(string: agent.scrapableUrlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        
        let request = URLRequest(url: url)
        
        activeWebview = appropriateWebview()
        
        activeWebview?.navigationDelegate = self
        activeWebview?.load(request)

        resetIdlingTimer()
    }
    
    /// A function to determine if the membership card we are about to scrape can use our priority webview or not.
    /// The priority webview can support one membership card per membership plan.
    /// If we are already supporting a membership card of the same membership plan, we use an ephermeral webview that will only live as long as scraping is taking place.
    /// Only the priority web view can handle sessions and cookies in a user-friendly way.
    /// - Returns: The webview in which to perform points scraping
    private func appropriateWebview() -> WKWebView? {
        guard let card = membershipCard, let plan = card.membershipPlan else { return nil }
        
        let priorityCardIds = priorityScrapableCards.map { $0.cardId }
        let priorityPlanIds = priorityScrapableCards.map { $0.planId }
        
        if priorityCardIds.contains(card.id) {
            return priorityWebview
        }
        
        if priorityPlanIds.contains(plan.id) {
            return WKWebView(frame: .zero)
        } else {
            return priorityWebview
        }
    }
    
    private func stop() {
        agent = nil
        membershipCard = nil
        idleTimer?.invalidate()
        idleRetryCount = 0
        userActionTimer?.invalidate()
        isPerformingUserAction = false
        
        if activeWebview != priorityWebview {
            activeWebview = nil
        }
        
        try? Current.pointsScrapingManager.addNextQueuedCard()
    }

    private func resetIdlingTimer() {
        idleTimer?.invalidate()
        idleTimer = Timer.scheduledTimer(withTimeInterval: idleThreshold, repeats: false, block: { [weak self] timer in
            guard let self = self else { return }
            // The webview has sat idle for a period of time without performing any navigation.
            // If we don't force to failed, the card will remain in an unusable pending state.
            // But first, let's retry if we haven't already
            
            if self.idleRetryCount < self.idleRetryLimit {
                self.idleRetryCount += 1
                self.handleWebViewNavigation()
                return
            }
            
            timer.invalidate()
            self.finish(withError: .unhandledIdling)
        })
    }
    
    private func beginUserAction() {
        isPerformingUserAction = true
        presentWebView()
        userActionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.handleWebViewNavigation(stateConfigurator: .userActionRequired)
        })
    }
    
    private func endUserAction() {
        isPerformingUserAction = false
        userActionTimer?.invalidate()
        closeWebView()
        handleWebViewNavigation(stateConfigurator: .userActionComplete)
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

    private func script(scriptName: String) -> String? {
        guard let file = Bundle.main.url(forResource: scriptName, withExtension: "js") else {
            return nil
        }
        return try? String(contentsOf: file)
    }

    private func runScript(_ script: String, completion: @escaping (Result<WebScrapingResponse, WebScrapingUtilityError>) -> Void) {
        if isExecutingScript { return }
        isExecutingScript = true
        
        activeWebview?.evaluateJavaScript(script) { [weak self] (response, error) in
            self?.isExecutingScript = false
            
            guard error == nil else {
                completion(.failure(.javascriptError))
                return
            }
            
            guard let response = response else {
                completion(.failure(.noJavascriptResponse))
                return
            }

            do {
                let data = try JSONSerialization.data(withJSONObject: response, options: .prettyPrinted)
                let scrapingResponse = try JSONDecoder().decode(WebScrapingResponse.self, from: data)
                completion(.success(scrapingResponse))
            } catch {
                completion(.failure(.failedToDecodeJavascripResponse))
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
            
            priorityScrapableCards.removeAll(where: { $0.cardId == membershipCard.id })
        }
    }

    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return membershipCard?.id == card.id
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        handleWebViewNavigation()
    }
    
    enum WebScrapingStateConfigurator: String {
        case userActionRequired
        case userActionComplete
    }

    private func handleWebViewNavigation(stateConfigurator: WebScrapingStateConfigurator? = nil) {
        resetIdlingTimer()
        guard let agent = agent else { return }
        guard let script = script(scriptName: agent.navigateScriptFileName) else {
            finish(withError: .scriptFileNotFound)
            return
        }
        guard let card = membershipCard, let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: card.id) else {
            return
        }
        
        let formattedScript = String(format: script, credentials.username, credentials.password, stateConfigurator?.rawValue ?? "")
        runScript(formattedScript) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if let error = response.errorMessage {
                    if response.didAttemptLogin == true {
                        self.finish(withError: .incorrectCredentials(errorMessage: error))
                    } else {
                        self.finish(withError: .genericFailure(errorMessage: error))
                    }
                    return
                }
                
                
                // User action
                
                if response.userActionComplete == true {
                    self.endUserAction()
                    return
                }
                
                if response.userActionRequired == true {
                    self.beginUserAction()
                    return
                }
                
                
                // Login attempt
                
                if response.didAttemptLogin == true {
                    if let card = self.membershipCard, self.activeWebview == self.priorityWebview {
                        /// At this point, we know we've attempted a login so there was no valid session
                        /// As we are using the priority web view, we know the membership card is the only one of it's plan type
                        /// We can safely assume the membership card can be move to the priority list and have it's session reused
                        if let priorityCard = PriorityScrapableCard(membershipCard: card) {
                            self.priorityScrapableCards.append(priorityCard)
                        }
                    }
                    
                    if Current.pointsScrapingManager.isDebugMode, let agent = self.agent {
                        DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - Attempted to log in", type: .success)
                    }
                }
                
                
                // Points retrieval

                if let points = response.pointsValue {
                    self.finish(withValue: points)
                    return
                }
            case .failure(let error):
                self.finish(withError: error)
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
