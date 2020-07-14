//
//  WebScrapingUtility.swift
//  binkapp
//
//  Created by Nick Farrant on 08/06/2020.
//  Copyright © 2020 Bink. All rights reserved.
//

import UIKit
import WebKit

protocol WebScrapable {
    var membershipPlanId: Int { get }
    var merchantName: String { get }
    var loyaltySchemeName: String { get }
    var loyaltySchemeBalanceCurrency: String? { get }
    var loyaltySchemeBalanceSuffix: String? { get }
    var loyaltySchemeBalancePrefix: String? { get }
    var scrapableUrlString: String { get }
    var loginScriptFileName: String { get }
    var pointsScrapingScriptFileName: String { get }
}

enum WebScrapingUtilityError: BinkError {
    case agentProvidedInvalidUrl
    case loginScriptFileNotFound
    case scapingScriptFileNotFound
    case agentProvidedInvalidLoginScript
    case agentProvidedInvalidScrapeScript
    case failedToExecuteLoginScript
    case failedToExecuteScrapingScript
    case failedToCastReturnValue
    
    var domain: BinkErrorDomain {
        return .webScrapingUtility
    }
    
    var message: String {
        return ""
    }
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String, forMembershipCardId cardId: String, withAgent agent: WebScrapable)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError)
}

struct WebScrapingCredentials {
    let username: String
    let password: String
}

class WebScrapingUtility: NSObject {
    private weak var containerViewController: UIViewController?
    private let webView: WKWebView
    private let agent: WebScrapable
    private let membershipCardId: String
    weak var delegate: WebScrapingUtilityDelegate?
    
    init(containerViewController: UIViewController, agent: WebScrapable, membershipCardId: String, delegate: WebScrapingUtilityDelegate?) {
        self.containerViewController = containerViewController
        webView = WKWebView(frame: .zero)
        self.agent = agent
        self.membershipCardId = membershipCardId
        self.delegate = delegate
        super.init()
        setupWebView()
    }
    
    private func setupWebView() {
        containerViewController?.view.addSubview(webView)
    }
    
    func start() throws {
        guard let url = URL(string: agent.scrapableUrlString) else {
            throw WebScrapingUtilityError.agentProvidedInvalidUrl
        }
        let request = URLRequest(url: url)
        let allCookies = HTTPCookieStorage.shared.cookies ?? []
        var cookiesSet: Int = 0
        for cookie in allCookies {
            webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                cookiesSet += 1
                if cookiesSet == allCookies.count {
                    self.webView.navigationDelegate = self
                    self.webView.load(request)
                }
            }
        }
    }
    
    func login(agent: WebScrapable, credentials: WebScrapingCredentials) throws {
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
            guard let self = self else {
                return
            }
            guard error == nil else {
                self.delegate?.webScrapingUtility(self, didCompleteWithError: .failedToExecuteLoginScript)
                return
            }
        }
    }

    func getScrapedValue(completion: @escaping (Result<String, WebScrapingUtilityError>) -> Void) {
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
            guard let self = self else {
                return
            }
            guard error == nil else {
                self.delegate?.webScrapingUtility(self, didCompleteWithError: .failedToExecuteScrapingScript)
                return
            }
            
            guard let pointsValue = pointsValue as? String, !pointsValue.isEmpty else {
                completion(.failure(.failedToCastReturnValue))
                return
            }
            
            self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
            
            completion(.success(pointsValue))
        }
    }
    
    private func runScript(_ script: String, completion: @escaping (Any?, Error?) -> Void) {
        webView.evaluateJavaScript(script, completionHandler: completion)
    }
    
    private var canScrape: Bool {
        return webView.url?.absoluteString == agent.scrapableUrlString
    }
}

extension WebScrapingUtility: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if canScrape {
            getScrapedValue { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .failure(let error):
                    // Often, this will throw as the page is loading, and succeed after a few runs of this method. So maybe we shouldn't throw here.
                    self.delegate?.webScrapingUtility(self, didCompleteWithError: error)
                    return
                case .success(let pointsValue):
                    self.delegate?.webScrapingUtility(self, didCompleteWithValue: pointsValue, forMembershipCardId: self.membershipCardId, withAgent: self.agent)
                }
            }
        } else {
            if let credentials = try? Current.pointsScrapingManager.retrieveCredentials(forMembershipCardId: membershipCardId) {
                try? login(agent: agent, credentials: credentials)
            }
        }
    }
}
