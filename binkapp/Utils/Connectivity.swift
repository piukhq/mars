//
//  Conectivity.swift
//  binkapp
//
//  Created by Paul Tiriteu on 09/09/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Alamofire

class Connectivity {
    class func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
