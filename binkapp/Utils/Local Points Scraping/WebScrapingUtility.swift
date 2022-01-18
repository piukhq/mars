//
//  WebScrapingUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit
import FirebaseStorage

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
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, item: PointsScrapingManager.QueuedItem, withAgent agent: LocalPointsCollectable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, item: PointsScrapingManager.QueuedItem, withAgent agent: LocalPointsCollectable)
}

class WebScrapingUtility: NSObject {
    var isExecutingScript = false
    private var isRunning: Bool {
        return item != nil || agent != nil
    }
    
    private let priorityWebview: WKWebView
    private var activeWebview: WKWebView?
    private var priorityScrapableCards: [PriorityScrapableCard] = []
    
    private var agent: LocalPointsCollectable?
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
    
    func start(agent: LocalPointsCollectable, item: PointsScrapingManager.QueuedItem) throws {
        /// If we have a membership card or agent, then we are currently in the process of scraping and should not be interrupted
        guard !isRunning else {
            SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Web scraping utility is already running and will not continue"))
            return
        }
        
        self.agent = agent
        MixpanelUtility.startTimer(for: .localPointsCollectionSuccess(brandName: agent.merchant ?? "Unknown"))
        
        guard let urlString = agent.pointsCollectionUrlString, let url = URL(string: urlString) else {
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
        
        defer {
            if activeWebview == priorityWebview {
                SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Active webview set to priority webview"))
            } else {
                SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Active webview set to ephemeral webview"))
            }
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
                    defaultDataStore.removeData(
                        ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                        for: records.filter {
                            if let merchant = agent.merchant {
                                return $0.displayName.contains(merchant)
                            }
                            return false
                        }) {
                            completion(.success(self.priorityWebview))
                            return
                    }
                }
            }
        }
    }
    
    func stop() {
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Web scraping utility stopped"))
        
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
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Resetting idle timer"))
        
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
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Beginning user action"))
        
        isPerformingUserAction = true
        presentWebView()
        userActionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.handleWebViewNavigation(stateConfigurator: .userActionRequired)
        })
    }
    
    private func endUserAction() {
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Ending user action"))
        
        isPerformingUserAction = false
        userActionTimer?.invalidate()
        closeWebView()
        handleWebViewNavigation(stateConfigurator: .userActionComplete)
    }
    
    private func presentWebView() {
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Presenting web view"))
        
        guard !isPresentingWebView else { return }
        guard let activeWebview = activeWebview else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let viewController = WebScrapingViewController(webView: activeWebview, delegate: self)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    private func closeWebView(force: Bool = false) {
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Closing web view"))
        
        if !force, isInDebugMode { return }
        if isPresentingWebView {
            Current.navigate.close()
        }
    }
    
    private func fetchScriptFile(merchant: LocalPointsCollectableMerchant, completion: @escaping (String?) -> Void) {
        let storage = Storage.storage()
        let pathReference = storage.reference(withPath: "local-points-collection/\(merchant.lowercased()).js")
        
        pathReference.getData(maxSize: 1 * 1024 * 1024) { data, _ in
            guard let data = data else {
                completion(nil)
                return
            }
            completion(String(data: data, encoding: .utf8))
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
        
        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Executing script"))
        
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
            if Current.pointsScrapingManager.isDebugMode, let merchant = agent.merchant?.capitalized {
                DebugInfoAlertView.show("\(merchant) LPC - Retreived points balance", type: .success)
            }
            delegate?.webScrapingUtility(self, didCompleteWithValue: value, item: item, withAgent: agent)
            
            SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Finishing with value"))
        }
        
        if let error = error {
            if Current.pointsScrapingManager.isDebugMode, let merchant = agent.merchant?.capitalized {
                DispatchQueue.main.async {
                    DebugInfoAlertView.show("\(merchant) LPC - \(error.localizedDescription)", type: .failure)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.presentWebView()
                }
            }
            delegate?.webScrapingUtility(self, didCompleteWithError: error, item: item, withAgent: agent)
            
            SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Finishing with error: \(error.localizedDescription)"))
            
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
        guard let merchant = agent.merchant else { return }
        
        fetchScriptFile(merchant: merchant) { [weak self] script in
            guard let self = self else { return }
            guard let script = script else { return }
            
            guard let card = self.item?.card, let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: card.id) else {
                return
            }
            
            var configString = ""
            if let stateConfig = stateConfigurator {
                configString = stateConfig.rawValue
            } else if self.sessionHasAttemptedLogin {
                configString = WebScrapingStateConfigurator.skipLogin.rawValue
            }
            
            SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Handling webview navigation"))
            SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Script config: \(configString)"))
            
            let formattedScript = String(format: script, credentials.username, credentials.password, configString, credentials.cardNumber ?? "")
            self.runScript(formattedScript) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if let error = response.errorMessage {
                        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Site error detected"))
                        
                        if response.didAttemptLogin == true {
                            SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Site did detect login attempt before error: \(error)"))
                            self.finish(withError: .incorrectCredentials(errorMessage: error))
                        } else {
                            self.finish(withError: .genericFailure(errorMessage: error))
                        }
                        return
                    }
                    
                    
                    // User action
                    
                    if response.userActionComplete == true {
                        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Site detected completed user action"))
                        self.endUserAction()
                        return
                    }
                    
                    if response.userActionRequired == true {
                        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Site detected user action required"))
                        self.beginUserAction()
                        return
                    }
                    
                    
                    // Login attempt
                    
                    if response.didAttemptLogin == true {
                        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Site detected login attempt"))
                        self.sessionHasAttemptedLogin = true
                        if let card = self.item?.card, self.activeWebview == self.priorityWebview {
                            /// At this point, we know we've attempted a login so there was no valid session
                            /// As we are using the priority web view, we know the membership card is the only one of it's plan type
                            /// We can safely assume the membership card can be move to the priority list and have it's session reused
                            if let priorityCard = PriorityScrapableCard(membershipCard: card), !self.priorityScrapableCards.contains(priorityCard) {
                                self.priorityScrapableCards.append(priorityCard)
                            }
                        }
                        
                        if Current.pointsScrapingManager.isDebugMode, let merchant = agent.merchant?.capitalized {
                            DebugInfoAlertView.show("\(merchant) LPC - Attempted to log in", type: .success)
                        }
                    }
                    
                    
                    // Points retrieval
                    
                    if let points = response.pointsValue {
                        SentryService.recordBreadcrumb(LocalPointsCollectionSentryBreadcrumb(message: "Site detected points value"))
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
