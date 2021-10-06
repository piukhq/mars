//
//  SafariWebExtensionHandler.swift
//  binksafari Extension
//
//  Created by Nick Farrant on 04/10/2021.
//  Copyright © 2021 Bink. All rights reserved.
//

import SafariServices
import os.log

class SafariWebExtensionHandler: NSObject, NSExtensionRequestHandling {

    func beginRequest(with context: NSExtensionContext) {
        let item = context.inputItems[0] as! NSExtensionItem
        let message = item.userInfo?[SFExtensionMessageKey]
        os_log(.default, "Received message from browser.runtime.sendNativeMessage: %@", message as! CVarArg)

        let response = NSExtensionItem()
        response.userInfo = [ SFExtensionMessageKey: [ "Response to": message ] ]
        
        var issuedVouchers: [IssuedVoucher] = []
        if let archiveUrl = FileManager.sharedContainerURL()?.appendingPathComponent("voucher_codes.json") {
            let decoder = JSONDecoder()
            if let data = try? Data(contentsOf: archiveUrl) {
                if let voucherCodes = try? decoder.decode([IssuedVoucher].self, from: data) {
                    voucherCodes.forEach {
                        issuedVouchers.append($0)
                    }
                }
            }
        }
        
//
//        var contents: [WidgetContent] = []
//        guard let archiveURL = FileManager.sharedContainerURL()?.appendingPathComponent("contents.json") else { return contents }
//
//        let decoder = JSONDecoder()
//        if let codeData = try? Data(contentsOf: archiveURL) {
//            do {
//                let widgetContent = try decoder.decode(WidgetContent.self, from: codeData)
//                contents.append(widgetContent)
//            } catch {
//                if #available(iOS 14.0, *) {
//                    BinkLogger.error(AppLoggerError.decodeWidgetContentsFromDiskFailure, value: error.localizedDescription)
//                }
//            }
//        }
        

        context.completeRequest(returningItems: [response], completionHandler: nil)
    }

}
