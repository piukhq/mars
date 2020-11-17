//
//  WebScrapingUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup

enum WebScrapableMerchant: String {
    case tesco
    case boots
    case morrisons
    case superdrug
    case waterstones
    case heathrow
    case perfumeshop
}

protocol WebScrapable {
    var merchant: WebScrapableMerchant { get }
    var membershipPlanId: Int { get }
    var usernameFieldTitle: String { get }
    var passwordFieldTitle: String { get }
    var loyaltySchemeBalanceCurrency: String? { get }
    var loyaltySchemeBalanceSuffix: String? { get }
    var loyaltySchemeBalancePrefix: String? { get }
    var loginUrlString: String { get }
    var scrapableUrlString: String { get }
    var loginScriptFileName: String { get }
    var pointsScrapingScriptFileName: String { get }
    var detectTextScriptFileName: String { get }
    var reCaptchaPresentationType: WebScrapingUtility.ReCaptchaPresentationType { get }
    var reCaptchaPresentationFrequency: WebScrapingUtility.ReCaptchaPresentationFrequency { get }
    var reCaptchaTextIdentiferClass: String? { get }
    var reCaptchaMessage: String? { get }
    var incorrectCredentialsMessage: String? { get }
    var incorrectCredentialsTextIdentiferClass: String? { get }
    func pointsValueFromCustomHTMLParser(_ html: String) -> String?
}

extension WebScrapable {
    var loginScriptFileName: String {
        return "\(merchant.rawValue.capitalized)Login"
    }
    
    var pointsScrapingScriptFileName: String {
        return "\(merchant.rawValue.capitalized)PointsScrape"
    }
    
    var detectTextScriptFileName: String {
        return "DetectText"
    }

    func pointsValueFromCustomHTMLParser(_ html: String) -> String? { return nil }
}

enum WebScrapingUtilityError: BinkError {
    case agentProvidedInvalidUrl
    case loginScriptFileNotFound
    case scapingScriptFileNotFound
    case detectTextScriptFileNotFound
    case agentProvidedInvalidLoginScript
    case agentProvidedInvalidScrapeScript
    case invalidDetectTextScript
    case failedToExecuteLoginScript
    case failedToExecuteScrapingScript
    case failedToExecuteDetectTextScript
    case failedToCastReturnValue
    case loginFailed
    case userDismissedWebView
    
    var domain: BinkErrorDomain {
        return .webScrapingUtility
    }
    
    var message: String {
        switch self {
        case .agentProvidedInvalidUrl:
            return "Agent provided invalid URL"
        case .loginScriptFileNotFound:
            return "Login script file not found"
        case .scapingScriptFileNotFound:
            return "Scraping script file not found"
        case .agentProvidedInvalidLoginScript:
            return "Agent provided invalid login script"
        case .agentProvidedInvalidScrapeScript:
            return "Agent provided invalid scrape script"
        case .failedToExecuteLoginScript:
            return "Failed to execute login script"
        case .failedToExecuteScrapingScript:
            return "Failed to execute scraping script"
        case .failedToCastReturnValue:
            return "Failed to cast return value"
        case .loginFailed:
            return "Login failed"
        case .detectTextScriptFileNotFound:
            return "Detect text script file not found"
        case .invalidDetectTextScript:
            return "Invalid detect text script"
        case .failedToExecuteDetectTextScript:
            return "Failed to execute detect text script"
        case .userDismissedWebView:
            return "User dismissed webview"
        }
    }
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
}

struct WebScrapingCredentials {
    let username: String
    let password: String
}

class WebScrapingUtility: NSObject {
    enum ReCaptchaPresentationType {
        case persistent // reCaptcha is presented as soon as the login screen is loaded
        case reactive // reCaptcha is presented once a login has been attempted
        case none // reCaptcha is never presented to the user
    }
    
    enum ReCaptchaPresentationFrequency {
        case always // reCaptcha is presented every time
        case sometimes // reCaptcha is presented sometimes
        case never // reCaptcha is never presented to the user
    }
    
    private let webView: WKWebView
    private let agent: WebScrapable
    private let membershipCard: CD_MembershipCard
    private var hasAttemptedLogin = false
    private var hasCompletedLogin = false
    private var canAttemptToDetectReCaptcha = false
    private var canAttemptToDetectIncorrectCredentials = false
    private var isPresentingWebView: Bool {
        guard let navigationViewController = UIViewController.topMostViewController() as? UINavigationController else { return false }
        guard let topViewController = navigationViewController.viewControllers.first else { return false }
        return topViewController.view.subviews.contains(webView)
    }
    private var isBalanceRefresh: Bool {
        guard let balances = membershipCard.formattedBalances, !balances.isEmpty else { return false }
        return true
    }
    private weak var delegate: WebScrapingUtilityDelegate?
    
    init(agent: WebScrapable, membershipCard: CD_MembershipCard, delegate: WebScrapingUtilityDelegate?) {
        webView = WKWebView(frame: .zero)
        self.agent = agent
        self.membershipCard = membershipCard
        self.delegate = delegate
        super.init()
    }
    
    func start() throws {
        /// If we are refreshing the balance, we should try to access the scrapable url straight away, otherwise we know we'll need to login
        let urlString = isBalanceRefresh ? agent.scrapableUrlString : agent.loginUrlString
        guard let url = URL(string: urlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        
        if Current.userDefaults.bool(forDefaultsKey: .lpcDebugWebView) {
            presentWebView()
        }
        
        let request = URLRequest(url: url)
        
        guard Current.userDefaults.bool(forDefaultsKey: .lpcUseCookies) else {
            self.webView.navigationDelegate = self
            self.webView.load(request)
            return
        }
        
        if let cookiesDictionary = Current.userDefaults.value(forDefaultsKey: .webScrapingCookies(membershipCardId: membershipCard.id)) as? [String: Any] {
            var cookiesSet: Int = 0
            for (_, cookieProperties) in cookiesDictionary {
                if let properties = cookieProperties as? [HTTPCookiePropertyKey: Any], let cookie = HTTPCookie(properties: properties) {
                    webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                        cookiesSet += 1
                        if cookiesSet == cookiesDictionary.count {
                            self.webView.navigationDelegate = self
                            self.webView.load(request)
                        }
                    }
                }
            }
        } else {
            self.webView.navigationDelegate = self
            self.webView.load(request)
        }
    }
    
    private func presentWebView() {
        guard !isPresentingWebView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let viewController = WebScrapingViewController(webView: self.webView, delegate: self)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }
    
    private func login(credentials: WebScrapingCredentials) throws {
        guard let loginFile = Bundle.main.url(forResource: agent.loginScriptFileName, withExtension: "js") else {
            throw WebScrapingUtilityError.loginScriptFileNotFound
        }
        
        var loginScript: String
        
        do {
            loginScript = try String(contentsOf: loginFile)
        } catch {
            throw WebScrapingUtilityError.agentProvidedInvalidLoginScript
        }
        
        // Inject variables into login file
        let formattedLoginScript = String(format: loginScript, credentials.username, credentials.password)
        runScript(formattedLoginScript) { [weak self] (_, error) in
            guard let self = self else { return }
            guard error == nil else {
                self.delegate?.webScrapingUtility(self, didCompleteWithError: .failedToExecuteLoginScript, forMembershipCard: self.membershipCard, withAgent: self.agent)
                return
            }
            
            if self.agent.reCaptchaPresentationType == .persistent && self.agent.reCaptchaPresentationFrequency == .always {
                // At this point we know that the user will be presented with a reCaptcha, and we'll have already filled their credentials so we should present the webview
                self.presentWebView()
            }
        }
    }

    private func getScrapedValue(completion: @escaping (Result<String, WebScrapingUtilityError>) -> Void) {
        guard let scrapeFile = Bundle.main.url(forResource: agent.pointsScrapingScriptFileName, withExtension: "js") else {
            completion(.failure(.scapingScriptFileNotFound))
            return
        }
        
        var scrapeScript: String
        
        do {
            scrapeScript = try String(contentsOf: scrapeFile)
        } catch {
            completion(.failure(.agentProvidedInvalidScrapeScript))
            return
        }

        runScript(scrapeScript) { [weak self] (pointsValue, error) in
            guard let self = self else { return }
            guard error == nil else {
                self.delegate?.webScrapingUtility(self, didCompleteWithError: .failedToExecuteScrapingScript, forMembershipCard: self.membershipCard, withAgent: self.agent)
                return
            }
            
            guard let pointsValue = pointsValue as? String, !pointsValue.isEmpty else {
                completion(.failure(.failedToCastReturnValue))
                return
            }
            
            self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                guard Current.userDefaults.bool(forDefaultsKey: .lpcUseCookies) else { return }
                var cookiesDictionary: [String: Any] = [:]
                for cookie in cookies {
                    cookiesDictionary[cookie.name] = cookie.properties
                }
                Current.userDefaults.set(cookiesDictionary, forDefaultsKey: .webScrapingCookies(membershipCardId: self.membershipCard.id))
            }

//            let html = "<div class='span5 plus-col-balance alpha'>Current <span class='inline-plus'>plus</span> Balance: <strong>£0.00</strong></div>"
//            let doc = try? SwiftSoup.parse(html)
//            let paragraphs = try? doc?.select("p")
//            let points = try? paragraphs?.first()?.text()
            
            completion(.success(self.agent.pointsValueFromCustomHTMLParser(pointsValue) ?? pointsValue))
        }
    }
    
    enum DetectTextType {
        case reCaptchaMessaging
        case incorrectCredentialsMessaging
    }
    
    // TODO: Make this more scalable. Callsite should handle the completion logic
    private func detectText(_ type: DetectTextType) throws {
        // Disable reCaptcha detection on balance refresh
        if type == .reCaptchaMessaging, isBalanceRefresh { return }
        
        switch type {
        case .reCaptchaMessaging:
            self.canAttemptToDetectReCaptcha = false
        case .incorrectCredentialsMessaging:
            self.canAttemptToDetectIncorrectCredentials = false
        }
        
        guard let detectTextScriptFile = Bundle.main.url(forResource: agent.detectTextScriptFileName, withExtension: "js") else {
            throw WebScrapingUtilityError.detectTextScriptFileNotFound
        }
        
        var detectTextScript: String
        do {
            detectTextScript = try String(contentsOf: detectTextScriptFile)
        } catch {
            throw WebScrapingUtilityError.invalidDetectTextScript
        }
        var formattedScript: String
        switch type {
        case .reCaptchaMessaging:
            formattedScript = String(format: detectTextScript, agent.reCaptchaTextIdentiferClass ?? "")
        case .incorrectCredentialsMessaging:
            formattedScript = String(format: detectTextScript, agent.incorrectCredentialsTextIdentiferClass ?? "")
        }
        
        runScript(formattedScript) { (value, _) in
            guard let valueString = value as? String else {
                switch type {
                case .reCaptchaMessaging:
                    self.canAttemptToDetectReCaptcha = true
                case .incorrectCredentialsMessaging:
                    self.canAttemptToDetectIncorrectCredentials = true
                }
                return
            }
            
            switch type {
            case .reCaptchaMessaging:
                guard let message = self.agent.reCaptchaMessage, valueString.contains(message) else {
                    self.canAttemptToDetectReCaptcha = true
                    return
                }
            case .incorrectCredentialsMessaging:
                guard let message = self.agent.incorrectCredentialsMessage, valueString.contains(message) else {
                    self.canAttemptToDetectIncorrectCredentials = true
                    return
                }
            }
            
            switch type {
            case .reCaptchaMessaging:
                self.presentWebView()
                self.canAttemptToDetectReCaptcha = false
            case .incorrectCredentialsMessaging:
                self.canAttemptToDetectIncorrectCredentials = false
                self.delegate?.webScrapingUtility(self, didCompleteWithError: .loginFailed, forMembershipCard: self.membershipCard, withAgent: self.agent)
                // At this point, we should close the webView if we have displayed it for reCaptcha
                if self.isPresentingWebView {
                    Current.navigate.close()
                }
            }
        }
    }
    
    private func runScript(_ script: String, completion: @escaping (Any?, Error?) -> Void) {
        webView.evaluateJavaScript(script, completionHandler: completion)
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
        return webView.url?.absoluteString.starts(with: agent.loginUrlString) == true
    }
    
    private var isLikelyAtScrapableScreen: Bool {
        guard agent.loginUrlString != agent.scrapableUrlString else {
            // This agent has the same url for login and scraping
            // If we have attempted login, we may be able to scrape here
            return hasAttemptedLogin
        }
        return webView.url?.absoluteString.starts(with: agent.scrapableUrlString) == true
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        canAttemptToDetectReCaptcha = true
        canAttemptToDetectIncorrectCredentials = true
        
        // We only care about the webview navigation to our agent's login url or scrapable url
        guard !isRedirecting else { return }
        
        if shouldScrape {
            // If we should scrape, we know we've successfully logged in.
            hasCompletedLogin = true
            
            // At this point, we should close the webView if we have displayed it for reCaptcha
            if isPresentingWebView {
                Current.navigate.close()
            }
            
            getScrapedValue { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    self.delegate?.webScrapingUtility(self, didCompleteWithError: error, forMembershipCard: self.membershipCard, withAgent: self.agent)
                case .success(let pointsValue):
                    self.delegate?.webScrapingUtility(self, didCompleteWithValue: pointsValue, forMembershipCard: self.membershipCard, withAgent: self.agent)
                }
            }
        } else {
            do {
                let credentials = try Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: membershipCard.id)
                if shouldAttemptLogin {
                    hasAttemptedLogin = true
                    try login(credentials: credentials)
                    // TODO: what if login failed, but the webview doesnt trigger navigation? We just sit here
                } else {
                    // We should only fall into here if we know we are at the login url, but we've already attempted a login
                    self.delegate?.webScrapingUtility(self, didCompleteWithError: .loginFailed, forMembershipCard: self.membershipCard, withAgent: self.agent)
                }
            } catch {
                if let webScrapingError = error as? WebScrapingUtilityError {
                    self.delegate?.webScrapingUtility(self, didCompleteWithError: webScrapingError, forMembershipCard: self.membershipCard, withAgent: self.agent)
                } else {
                    self.delegate?.webScrapingUtility(self, didCompleteWithError: .loginFailed, forMembershipCard: self.membershipCard, withAgent: self.agent)
                }
            }
        }
    }
    
    @available(iOS 13.0, *)
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        if canAttemptToDetectReCaptcha {
            do {
                try detectText(.reCaptchaMessaging)
            } catch {
                canAttemptToDetectReCaptcha = true
            }
        }
        
        if canAttemptToDetectIncorrectCredentials {
            do {
                try detectText(.incorrectCredentialsMessaging)
            } catch {
                canAttemptToDetectIncorrectCredentials = true
            }
        }
        
        decisionHandler(.allow, preferences)
    }
}

extension WebScrapingUtility: WebScrapingViewControllerDelegate {
    func webScrapingViewControllerDidDismiss(_ viewController: WebScrapingViewController) {
        if !hasCompletedLogin {
            delegate?.webScrapingUtility(self, didCompleteWithError: .userDismissedWebView, forMembershipCard: membershipCard, withAgent: agent)
        }
    }
}

protocol WebScrapingViewControllerDelegate: AnyObject {
    func webScrapingViewControllerDidDismiss(_ viewController: WebScrapingViewController)
}

class WebScrapingViewController: UIViewController {
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
