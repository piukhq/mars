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
}

enum WebScrapingUtilityError: BinkError {
    case agentProvidedInvalidUrl
    case loginScriptFileNotFound
    case scapingScriptFileNotFound
    case detectReCaptchaScriptFileNotFound
    case agentProvidedInvalidLoginScript
    case agentProvidedInvalidScrapeScript
    case invalidDetectReCaptchaScript
    case failedToExecuteLoginScript
    case failedToExecuteScrapingScript
    case failedToCastReturnValue
    case loginFailed
    
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
        case .detectReCaptchaScriptFileNotFound:
            return "Detect reCaptcha script file not found"
        case .invalidDetectReCaptchaScript:
            return "Invalid detect reCaptcha script"
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
    private weak var containerViewController: UIViewController?
    private let webView: WKWebView
    private let agent: WebScrapable
    private let membershipCard: CD_MembershipCard
    private var hasAttemptedLogin = false
    private var shouldDetectReCaptcha = true
    private weak var delegate: WebScrapingUtilityDelegate?
    
    init(containerViewController: UIViewController, agent: WebScrapable, membershipCard: CD_MembershipCard, delegate: WebScrapingUtilityDelegate?) {
        self.containerViewController = containerViewController
        webView = WKWebView(frame: .zero)
        self.agent = agent
        self.membershipCard = membershipCard
        self.delegate = delegate
        super.init()
    }
    
    func start() throws {
        guard let url = URL(string: agent.scrapableUrlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        
        if Current.userDefaults.bool(forDefaultsKey: .lpcDebugWebView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let webViewController = UIViewController()
                self.webView.frame = webViewController.view.frame
                webViewController.view.addSubview(self.webView)
                self.containerViewController?.present(webViewController, animated: true, completion: nil)
                let navigationRequest = ModalNavigationRequest(viewController: webViewController)
                Current.navigate.to(navigationRequest)
            }
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
        runScript(formattedLoginScript) { [weak self] (value, error) in
            guard let self = self else { return }
            guard error == nil else {
                self.delegate?.webScrapingUtility(self, didCompleteWithError: .failedToExecuteLoginScript, forMembershipCard: self.membershipCard, withAgent: self.agent)
                return
            }
            // For Boots, after attempting to login the user will be presented with an error message and prompted to complete reCaptcha.
            // This doesn't result in the webview loading a new page, so we cannot detect this happening through delegate hooks.
            // So essentially, we will remain in this part of this method and the card will remain pending until a pull-to-refresh is performed.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                try? self.detectReCaptcha()
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
            
            completion(.success(pointsValue))
        }
    }
    
    private func detectReCaptcha() throws {
        guard let detectReCaptchaFile = Bundle.main.url(forResource: "detectReCaptcha", withExtension: "js") else {
            throw WebScrapingUtilityError.detectReCaptchaScriptFileNotFound
        }
        
        var detectReCaptchaScript: String
        
        do {
            detectReCaptchaScript = try String(contentsOf: detectReCaptchaFile)
        } catch {
            throw WebScrapingUtilityError.invalidDetectReCaptchaScript
        }
        
        runScript(detectReCaptchaScript) { (value, error) in
            print(value ?? "")
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
        return webView.url?.absoluteString.starts(with: agent.scrapableUrlString) == true
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web scraping: web view did navigate")
        // We only care about the webview navigation to our agent's login url or scrapable url
        guard !isRedirecting else { return }
        
        if shouldScrape {
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
}
