//
//  JiraPost.swift
//  Created by Max Woodhams on 09/11/2020.
//

import Foundation

enum JiraPostError: Error {
    case cannotFormatAuth
    case unableToBuildURL
    case jsonEncodingIssue
    case httpRequestRejected
    case missingEnvVars
}

struct JiraPost {
    
    static var sema = DispatchSemaphore( value: 0 )

    enum CommentType: String {
        case acceptanceBuild = "acceptance"
        case mergeRequestBuild = "merge"
    }
    
    private enum EnvVars: String {
        case baseUrlString = "jiraBaseUrl"
        case email = "jiraUserEmail"
        case accessToken = "jiraAccessToken"
        case issueCode = "JIRA_ISSUE_CODE"
        case buildNumber = "BITRISE_BUILD_NUMBER"
        case commitMessage = "GIT_CLONE_COMMIT_MESSAGE_SUBJECT"
        case branch = "BITRISE_GIT_BRANCH"
        case author = "GIT_CLONE_COMMIT_AUTHOR_NAME"
    }
    
    private static func envVar(for variable: EnvVars) throws -> String {
        guard let envVar = ProcessInfo.processInfo.environment[variable.rawValue] else {
            throw JiraPostError.missingEnvVars
        }
        
        return envVar
    }
    
    static func post(with comment: CommentType) throws {
        
        let baseUrlString = try envVar(for: .baseUrlString)
        let issueCode = try envVar(for: .issueCode)
        let accessToken = try envVar(for: .accessToken)
        let userEmail = try envVar(for: .email)
        let buildNumber = try envVar(for: .buildNumber)
        let commitMessage = try envVar(for: .commitMessage)
        let branch = try envVar(for: .branch)
        let author = try envVar(for: .author)
        
        guard let url = URL(string: baseUrlString + "/rest/api/3/issue/" + issueCode + "/comment") else {
            throw JiraPostError.unableToBuildURL
        }
        
        let commentData = JiraComment.CommentData(buildNumber: buildNumber, commitMessage: commitMessage, branch: branch, author: author)
        let stringData = Data(JiraComment.comment(with: comment, data: commentData).utf8)
        let authData = try auth(with: userEmail, token: accessToken)
        
        // Setup basic URLSession
        let session = URLSession.shared
        var request = URLRequest(url: url)
        request.addValue(authData, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = stringData
        request.httpMethod = "POST"
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if let httpResponse = response as? HTTPURLResponse, error == nil, 200..<300 ~= httpResponse.statusCode {
                // Success!
                print("Successfully added comment to \(issueCode)")
                
                sema.signal()
            } else {
                
                print("Unable to add comment to \(issueCode)")
                sema.signal()
            }
        }
        
        task.resume()
        sema.wait()
    }
    
    private static func auth(with email: String, token: String) throws -> String {
        let authString = "\(email):\(token)"
        let utf8str = authString.data(using: .utf8)
        
        guard let base64Encoded = utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0)) else {
            throw JiraPostError.cannotFormatAuth
        }
        
        return "Basic " + base64Encoded
    }
}
