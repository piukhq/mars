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
    let cardNumber: String?
    
    init(username: String, password: String, cardNumber: String? = nil) {
        self.username = username
        self.password = password
        self.cardNumber = cardNumber
    }
}

struct PriorityScrapableCard: Equatable {
    let cardId: String
    let planId: String
    
    init?(membershipCard: CD_MembershipCard) {
        self.cardId = membershipCard.id
        guard let planId = membershipCard.membershipPlan?.id else { return nil }
        self.planId = planId
    }
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, item: PointsScrapingManager.QueuedItem, withAgent agent: WebScrapable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, item: PointsScrapingManager.QueuedItem, withAgent agent: WebScrapable)
}

class WebScrapingUtility: NSObject {
    var isExecutingScript = false
    private var isRunning: Bool {
        return item != nil || agent != nil
    }
    
    private let priorityWebview: WKWebView
    private var activeWebview: WKWebView?
    private var priorityScrapableCards: [PriorityScrapableCard] = []
    
    private var agent: WebScrapable?
    private var item: PointsScrapingManager.QueuedItem?
    
    private weak var delegate: WebScrapingUtilityDelegate?
    
    private var idleTimer: Timer?
    private let idleThreshold: TimeInterval = 20
    private let idleRetryLimit = 2
    private var idleRetryCount = 0
    private var sessionHasAttemptedLogin = false
    
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
        guard let balances = item?.card.formattedBalances, !balances.isEmpty else { return false }
        return true
    }
    
    init(delegate: WebScrapingUtilityDelegate?) {
        priorityWebview = WKWebView(frame: .zero)
        self.delegate = delegate
        super.init()
    }
    
    func start(agent: WebScrapable, item: PointsScrapingManager.QueuedItem) throws {
        /// If we have a membership card or agent, then we are currently in the process of scraping and should not be interrupted
        guard !isRunning else { return }
        
        self.agent = agent
        
        guard let url = URL(string: agent.scrapableUrlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        
        self.item = item
        item.isProcessing = true
        
        let request = URLRequest(url: url)
        
        getAppropriateWebview { [weak self] result in
            switch result {
            case .success(let webview):
                self?.activeWebview = webview
                
                DispatchQueue.main.async {
                    self?.activeWebview?.navigationDelegate = self
                    self?.activeWebview?.load(request)
                }
                
                self?.resetIdlingTimer()
            case .failure(let error):
                self?.finish(withError: error)
            }
        }
    }
    
    /// A function to determine if the membership card we are about to scrape can use our priority webview or not.
    /// The priority webview can support one membership card per membership plan.
    /// If we are already supporting a membership card of the same membership plan, we use an ephermeral webview that will only live as long as scraping is taking place.
    /// Only the priority web view can handle sessions and cookies in a user-friendly way.
    /// - Returns: The webview in which to perform points scraping
    private func getAppropriateWebview(completion: @escaping (Result<WKWebView, WebScrapingUtilityError>) -> Void) {
        guard let card = item?.card, let plan = card.membershipPlan, let agent = agent else {
            completion(.failure(.failedToAssignWebView))
            return
        }
        
        DispatchQueue.main.async {
            let priorityCardIds = self.priorityScrapableCards.map { $0.cardId }
            
            /// If performing a balance refresh, and the card is already assigned the priority web view, use it
            if self.isBalanceRefresh, priorityCardIds.contains(card.id) {
                completion(.success(self.priorityWebview))
                return
            }
            
            /// Get the priority web view's data store records
            let defaultDataStore = WKWebsiteDataStore.default()
            defaultDataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                /// Create an ephemeral web view that will only be used for this scraping run
                let config = WKWebViewConfiguration()
                config.websiteDataStore = WKWebsiteDataStore.nonPersistent()
                let ephermeralWebView = WKWebView(frame: .zero, configuration: config)
                
                /// Do we have a scrapable card already added for this plan?
                /// And if so, is it assigned to priority web view?
                let existingScrapableCardForPlan = self.priorityScrapableCards.first(where: { $0.planId == plan.id })
                if let existingCardIdForPlan = existingScrapableCardForPlan, priorityCardIds.contains(existingCardIdForPlan.cardId) {
                    /// If so, use ephemeral web view
                    completion(.success(ephermeralWebView))
                    return
                } else {
                    /// If not, use priority web view
                    /// Clear all merchant data from datastore first to ensure no conflicts
                    defaultDataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records.filter {
                        $0.displayName.contains(agent.merchant.rawValue)
                    }) {
                        completion(.success(self.priorityWebview))
                        return
                    }
                }
            }
        }
    }
    
    func stop() {
        agent = nil
        item = nil
        idleTimer?.invalidate()
        idleRetryCount = 0
        userActionTimer?.invalidate()
        isPerformingUserAction = false
        sessionHasAttemptedLogin = false
        
        if activeWebview != priorityWebview {
            activeWebview = nil
        }
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
        guard let item = item else { return }
        
        item.isProcessing = false
        
        if let value = value {
            if Current.pointsScrapingManager.isDebugMode {
                DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - Retreived points balance", type: .success)
            }
            delegate?.webScrapingUtility(self, didCompleteWithValue: value, item: item, withAgent: agent)
        }
        
        if let error = error {
            if Current.pointsScrapingManager.isDebugMode {
                DispatchQueue.main.async {
                    DebugInfoAlertView.show("\(agent.merchant.rawValue.capitalized) LPC - \(error.localizedDescription)", type: .failure)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.presentWebView()
                }
            }
            SentryService.triggerException(.localPointsCollectionFailed(error, agent.merchant, balanceRefresh: isBalanceRefresh))
            delegate?.webScrapingUtility(self, didCompleteWithError: error, item: item, withAgent: agent)
            
            priorityScrapableCards.removeAll(where: { $0.cardId == item.card.id })
        }
    }
    
    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return item?.card.id == card.id
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        handleWebViewNavigation()
    }
    
    enum WebScrapingStateConfigurator: String {
        case userActionRequired
        case userActionComplete
        case skipLogin
    }
    
    private func handleWebViewNavigation(stateConfigurator: WebScrapingStateConfigurator? = nil) {
        resetIdlingTimer()
        guard let agent = agent else { return }
        guard let script = script(scriptName: agent.navigateScriptFileName) else {
            finish(withError: .scriptFileNotFound)
            return
        }
        guard let card = item?.card, let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: card.id) else {
            return
        }
        
        var configString = ""
        if let stateConfig = stateConfigurator {
            configString = stateConfig.rawValue
        } else if self.sessionHasAttemptedLogin {
            configString = WebScrapingStateConfigurator.skipLogin.rawValue
        }
        
        let formattedScript = String(format: script, credentials.username, credentials.password, configString, credentials.cardNumber ?? "")
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
                    self.sessionHasAttemptedLogin = true
                    if let card = self.item?.card, self.activeWebview == self.priorityWebview {
                        /// At this point, we know we've attempted a login so there was no valid session
                        /// As we are using the priority web view, we know the membership card is the only one of it's plan type
                        /// We can safely assume the membership card can be move to the priority list and have it's session reused
                        if let priorityCard = PriorityScrapableCard(membershipCard: card), !self.priorityScrapableCards.contains(priorityCard) {
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
