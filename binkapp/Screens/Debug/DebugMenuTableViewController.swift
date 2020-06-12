//
//  DebugMenuTableViewController.swift
//  binkapp
//
//  Created by Nick Farrant on 02/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import UIKit
import WebKit

import ZendeskCoreSDK
import SupportSDK

import Kanna

class DebugMenuTableViewController: UITableViewController, ModalDismissable {
    
    private let viewModel: DebugMenuViewModel
    
    init(viewModel: DebugMenuViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = viewModel.title
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "close"), style: .plain, target: self, action: #selector(close))
        
        tableView.register(DebugMenuTableViewCell.self, asNib: true)
        tableView.register(DebugMenuSegmentedTableViewCell.self, asNib: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionsCount
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForSection(atIndex: section)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowsCount(forSectionAtIndex: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.sections.first?.rows[indexPath.row].cellType == DebugMenuRow.CellType.segmentedControl {
            let cell: DebugMenuSegmentedTableViewCell = tableView.dequeue(indexPath: indexPath)
            return cell
        }
        
        let cell: DebugMenuTableViewCell = tableView.dequeue(indexPath: indexPath)
        
        let row = viewModel.row(atIndexPath: indexPath)
        cell.configure(withDebugRow: row)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = viewModel.row(atIndexPath: indexPath)
        row.action?()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - ModalDismissable
    
    @objc func close() {
        dismiss(animated: true, completion: nil)
    }
}

extension DebugMenuTableViewController: DebugMenuFactoryDelegate {
    func debugMenuFactory(_ debugMenuFactory: DebugMenuFactory, shouldPerformActionForType type: DebugMenuRow.RowType) {
        switch type {
        case .endpoint:
            guard let navController = navigationController else { return }
            let alert = debugMenuFactory.makeEnvironmentAlertController(navigationController: navController)
            navController.present(alert, animated: true, completion: nil)
        case .secondaryColor:
            let viewController = DebugSecondaryPlanColorViewController()
            navigationController?.pushViewController(viewController, animated: true)
        case .webScraping:
            let webView = WKWebView(frame: view.frame) // TODO: Zero the frame
            view.addSubview(webView)
            webView.navigationDelegate = self
            
            let request = URLRequest(url: URL(string: "https://secure.tesco.com/Clubcard/MyAccount/home/Home")!)
            
            let allCookies = HTTPCookieStorage.shared.cookies ?? []
            var cookiesSet: Int = 0
            // We have 27 cookies on launch, 48 on all subsequent calls, then back to 27 when relaunching... weird!
            for cookie in allCookies {
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie) {
                    cookiesSet += 1
                    if cookiesSet == allCookies.count {
                        webView.load(request)
                    }
                }
            }
        default:
            return
        }
    }
}

extension DebugMenuTableViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Locate JS files
        guard let loginFile = Bundle.main.url(forResource: "TescoLogin", withExtension: "js") else {
            return
        }
        guard let scrapeFile = Bundle.main.url(forResource: "TescoPointsScrape", withExtension: "js") else {
            return
        }

        do {
            // Parse JS files as a strings
            let loginJS = try String(contentsOf: loginFile)
            let scrapeJS = try String(contentsOf: scrapeFile)
            
            // Inject variables into login file
            let formattedJS = String(format: loginJS, "nickjf89@icloud.com", "f48-9Xc-mRh-Low")

            // Run the formatted login script if we can
            webView.evaluateJavaScript(formattedJS) { (value, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                // We have successfully logged in, or successfully bailed on login as there is no form (should mean that we were already logged in)
                webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                    for cookie in cookies {
                        HTTPCookieStorage.shared.setCookie(cookie)
                    }
                }
                
                // Pull out the point value using our scraping script
                webView.evaluateJavaScript(scrapeJS) { (pointValue, error) in
                    if let pointValue = pointValue as? String {
                        
                        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { cookies in
                            for cookie in cookies {
                                HTTPCookieStorage.shared.setCookie(cookie)
                            }
                        }
                        
                        let alert = UIAlertController(title: "Success!", message: "You have \(pointValue) points!", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
