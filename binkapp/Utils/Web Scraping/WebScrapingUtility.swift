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
    var merchantName: String { get }
    var loyaltySchemeName: String { get }
    var loyaltySchemeBalanceIdentifier: String { get }
    var scrapableUrlString: String { get }
    var loginScriptFileName: String { get }
    var pointsScrapingScriptFileName: String { get }
}

struct TescoScrapingAgent: WebScrapable {
    var merchantName: String {
        return "Tesco"
    }
    
    var loyaltySchemeName: String {
        return "Tesco Clubcard"
    }
    
    var loyaltySchemeBalanceIdentifier: String {
        return "pts"
    }
    
    var scrapableUrlString: String {
        return "https://secure.tesco.com/Clubcard/MyAccount/home/Home"
    }
    
    var loginScriptFileName: String {
        return "TescoLogin"
    }
    
    var pointsScrapingScriptFileName: String {
        return "TescoPointsScrape"
    }
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
    
    var errorCode: String? {
        return nil
    }
    
    var message: String {
        return ""
    }
}

protocol WebScrapingUtilityDelegate: AnyObject {
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithValue value: String)
    func webScrapingUtility(_ utility: WebScrapingUtility, didCompleteWithError error: WebScrapingUtilityError)
    func webScrapingUtilityDidPromptForCredentials(_ utility: WebScrapingUtility, agent: WebScrapable)
}

struct WebScrapingCredentials {
    let username: String
    let password: String
}

class WebScrapingUtility: NSObject {
    private weak var containerViewController: UIViewController?
    private let webView: WKWebView
    private let agent: WebScrapable
    weak var delegate: WebScrapingUtilityDelegate?
    
    init(containerViewController: UIViewController, agent: WebScrapable, delegate: WebScrapingUtilityDelegate?) {
        self.containerViewController = containerViewController
        webView = WKWebView(frame: .zero)
        self.agent = agent
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
        // We have ~27 cookies on launch, ~48 on all subsequent calls, then back to ~27 when relaunching... weird!
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
    
    // TODO: Convert to throwing
    func getScrapedValue(completion: @escaping (String?, WebScrapingUtilityError?) -> Void) {
        guard let scrapeFile = Bundle.main.url(forResource: agent.pointsScrapingScriptFileName, withExtension: "js") else {
            completion(nil, .scapingScriptFileNotFound)
            return
        }
        
        var scrapeScript: String
        
        do {
            scrapeScript = try String(contentsOf: scrapeFile)
        } catch {
            completion(nil, .agentProvidedInvalidScrapeScript)
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
                completion(nil, .failedToCastReturnValue)
                return
            }
            
            self.webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                for cookie in cookies {
                    HTTPCookieStorage.shared.setCookie(cookie)
                }
            }
            
            completion(pointsValue, nil)
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
            getScrapedValue { [weak self] (scrapedValue, error) in
                guard let self = self else { return }
                
                if let error = error {
                    // Often, this will throw as the page is loading, and succeed after a few runs of this method. So maybe we shouldn't throw here.
                    self.delegate?.webScrapingUtility(self, didCompleteWithError: error)
                    return
                }
                
                guard let scrapedValue = scrapedValue else {
                    fatalError("Scraped value is nil, but we didn't pass an error.")
                }
                
                self.delegate?.webScrapingUtility(self, didCompleteWithValue: scrapedValue)
            }
        } else {
            delegate?.webScrapingUtilityDidPromptForCredentials(self, agent: agent)
        }
    }
}
