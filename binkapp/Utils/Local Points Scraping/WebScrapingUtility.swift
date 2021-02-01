//
//  WebScrapingUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit

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
}

extension WebScrapable {
    var loyaltySchemeBalanceCurrency: String? {
        return nil
    }

    var loyaltySchemeBalanceSuffix: String? {
        return nil
    }

    var loyaltySchemeBalancePrefix: String? {
        return nil
    }

    var loginScriptFileName: String {
        return "LocalPointsCollection_Login"
    }
    
    var pointsScrapingScriptFileName: String {
        return "LocalPointsCollection_Points"
    }
    
    var detectTextScriptFileName: String {
        return "DetectText"
    }

    var reCaptchaPresentationType: WebScrapingUtility.ReCaptchaPresentationType {
        return .none
    }

    var reCaptchaPresentationFrequency: WebScrapingUtility.ReCaptchaPresentationFrequency {
        return .never
    }

    var reCaptchaTextIdentiferClass: String? {
        return nil
    }
    
    var reCaptchaMessage: String? {
        return nil
    }

    var incorrectCredentialsMessage: String? {
        return nil
    }

    var incorrectCredentialsTextIdentiferClass: String? {
        return nil
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
    case loginFailed(errorMessage: String?)
    case userDismissedWebView
    case unhandledIdling
    case javascriptError
    case pointsScrapingFailed(errorMessage: String?)
    
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
        case .loginFailed(let errorMessage):
            if let error = errorMessage {
                return "Login failed - \(error)"
            }
            return "Login failed"
        case .detectTextScriptFileNotFound:
            return "Detect text script file not found"
        case .invalidDetectTextScript:
            return "Invalid detect text script"
        case .failedToExecuteDetectTextScript:
            return "Failed to execute detect text script"
        case .userDismissedWebView:
            return "User dismissed webview"
        case .unhandledIdling:
            return "Unhandled idling"
        case .javascriptError:
            return "Javascript error"
        case .pointsScrapingFailed(let errorMessage):
            if let error = errorMessage {
                return "Points scraping failed - \(error)"
            }
            return "Points scraping failed"
        }
    }
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: Int, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError, forMembershipCard card: CD_MembershipCard, withAgent agent: WebScrapable)
}

struct WebScrapingCredentials {
    let username: String
    let password: String
}

struct WebScrapingResponse: Codable {
    var success: Bool?
    var pointsString: String?
    var errorMessage: String?
    var userActionRequired: Bool?
    var elementDetected: Bool?

    var pointsValue: Int? {
        guard let string = pointsString else { return nil }
        return Int(string)
    }

    enum CodingKeys: String, CodingKey {
        case success
        case pointsString = "points"
        case errorMessage = "error_message"
        case userActionRequired = "user_action_required"
        case elementDetected = "element_detected"
    }
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

    private var isIdle = false
    private var idleTimer: Timer?
    private let idleThreshold: TimeInterval = 60

    private var isPerformingUserAction = false
    private var detectElementTimer: Timer?
    
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

        resetIdlingTimer()
    }

    private func resetIdlingTimer() {
//        idleTimer?.invalidate()
//        idleTimer = Timer.scheduledTimer(withTimeInterval: idleThreshold, repeats: false, block: { timer in
//            self.isIdle = true
//            timer.invalidate()
//
//            /// We check for incorrect credentials first, because if that is detected then we don't care about recaptcha
//            self.detectIncorrectCredentialsText { [weak self] textDetected in
//                guard let self = self else { return }
//                if !textDetected {
//                    /// We only need to handle the case where no text is detected, as the parent method handles the detection handling.
//                    /// In this case, the reason we are idling is not due to incorrect credentials, so we should check for recaptcha
//                    self.detectRecaptchaText { recaptchaDetected in
//                        /// Again, we only need to handle non-detection.
//                        /// In this case, we aren't idling because of incorrect credentials OR recaptcha, so let's fail the scraping with a reason of unhandled idling.
//                        if !recaptchaDetected {
//                            self.finish(withError: .unhandledIdling)
//                        }
//                    }
//                }
//            }
//        })
    }

    private func presentWebView() {
        guard !isPresentingWebView else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let viewController = WebScrapingViewController(webView: self.webView, delegate: self)
            let navigationRequest = ModalNavigationRequest(viewController: viewController)
            Current.navigate.to(navigationRequest)
        }
    }

    private func login(credentials: WebScrapingCredentials) {
        guard let script = script(scriptName: agent.loginScriptFileName) else {
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
                    self.isPerformingUserAction = true

                    if !self.isPresentingWebView {
                        self.presentWebView()
                    }

                    self.detectElementTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.detectRecaptchaSuccess), userInfo: nil, repeats: true)
                }
            case .failure:
                self.finish(withError: .failedToExecuteLoginScript)
            }
        }
    }

    @objc private func detectRecaptchaSuccess() {
        detectElement(queryString: "re-captcha[class*=-valid]") { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                if response.elementDetected == true {
                    self.detectElementTimer?.invalidate()
                    self.isPerformingUserAction = false

                    if self.isPresentingWebView {
                        if !Current.userDefaults.bool(forDefaultsKey: .lpcDebugWebView) {
                            Current.navigate.close()
                        }

                        guard let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: self.membershipCard.id) else {
                            self.finish(withError: .failedToExecuteLoginScript)
                            return
                        }
                        self.login(credentials: credentials)

                        // TODO: Continue with login using submit button only
                        // For morrisons, we can just run the login script again, and ignore captcha if the element is valid
                    }
                }
            case .failure:
                print("error")
            }
        }
    }

    private func getScrapedValue(completion: @escaping (Result<Int, WebScrapingUtilityError>) -> Void) {
        guard let script = script(scriptName: agent.pointsScrapingScriptFileName) else {
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
                self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    guard Current.userDefaults.bool(forDefaultsKey: .lpcUseCookies) else { return }
                    var cookiesDictionary: [String: Any] = [:]
                    for cookie in cookies {
                        cookiesDictionary[cookie.name] = cookie.properties
                    }
                    Current.userDefaults.set(cookiesDictionary, forDefaultsKey: .webScrapingCookies(membershipCardId: self.membershipCard.id))
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
        webView.evaluateJavaScript(script) { (response, error) in
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
        idleTimer?.invalidate()

        if let value = value {
            delegate?.webScrapingUtility(self, didCompleteWithValue: value, forMembershipCard: membershipCard, withAgent: agent)
        }

        if let error = error {
//            SentryService.triggerException(.localPointsCollectionFailed(error))
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

    func isCurrentlyScraping(forMembershipCard card: CD_MembershipCard) -> Bool {
        return membershipCard.id == card.id
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        resetIdlingTimer()
        canAttemptToDetectReCaptcha = true
        canAttemptToDetectIncorrectCredentials = true
        
        // We only care about the webview navigation to our agent's login url or scrapable url
        guard !isRedirecting else { return }
        
        if shouldScrape {
            // At this point, we should close the webView if we have displayed it for reCaptcha
            if isPresentingWebView {
                Current.navigate.close()
            }
            
            getScrapedValue { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .failure(let error):
                    self.finish(withError: error)
                case .success(let pointsValue):
                    self.finish(withValue: pointsValue)
                }
            }
        } else {
            do {
                let credentials = try Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: membershipCard.id)
                if shouldAttemptLogin {
                    hasAttemptedLogin = true
                    login(credentials: credentials)
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
//        resetIdlingTimer()
//
//        detectIncorrectCredentialsText { textDetected in
//            if !textDetected {
//                self.detectRecaptchaText()
//            }
//        }

        decisionHandler(.allow, preferences)
    }
}

extension WebScrapingUtility: WebScrapingViewControllerDelegate {
    func webScrapingViewControllerDidDismiss(_ viewController: WebScrapingViewController) {
        if isPerformingUserAction {
            self.finish(withError: .userDismissedWebView)
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
