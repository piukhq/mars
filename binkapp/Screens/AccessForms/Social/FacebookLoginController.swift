//
//  FacebookLoginController.swift
//  binkapp
//
//  Created by Max Woodhams on 03/11/2019.
//  Copyright © 2019 Bink. All rights reserved.
//

import Foundation
import FBSDKLoginKit

struct FacebookLoginController {
    static func login(with baseViewController: UIViewController, onSuccess: @escaping (_ request: FacebookRequest) -> (), onError: @escaping (_ error: Error?) -> ()) {
        
        let loginManager = LoginManager()
        
        loginManager.logIn(permissions: ["email"], from: baseViewController) { (result, error) in
            guard let token = AccessToken.current?.tokenString, let id = AccessToken.current?.userID, result?.isCancelled == false else {
                DispatchQueue.main.async {
                    onError(error)
                }
                return
            }
            
            var request = FacebookRequest(
                accessToken: token,
                email: nil,
                userId: id
            )
            
            /*
             If the user manually declines, our graph request will silently
             fail so check the declined permissions to save an API call.
             */
            if result?.declinedPermissions.contains("email") == true {
                DispatchQueue.main.async {
                    onSuccess(request)
                }
                
                return
            }
            
            // Perform graph request for email
            let graph = GraphRequest(graphPath: "me", parameters: ["fields":"email"])
            
            graph.start { (connection, result, error) in
                if let result = result as? [String: String], let resultEmail = result["email"] {
                    request.email = resultEmail
                }
                
                DispatchQueue.main.async {
                    onSuccess(request)
                }
            }
        }
    }
}
