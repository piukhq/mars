//
//  JiraComment.swift
//  Created by Max Woodhams on 09/11/2020.
//

import Foundation

struct JiraComment {
    struct CommentData {
        let buildNumber: String
        let commitMessage: String
        let branch: String
        let author: String?
    }
    
    static func comment(with commentType: JiraPost.CommentType, data: CommentData) -> String {
        switch commentType {
        case .acceptanceBuild:
            return acceptanceBody(with: data.buildNumber, commitMessage: data.commitMessage, branch: data.branch)
        case .mergeRequestBuild:
            return mergeRequestBody(with: data.buildNumber, commitMessage: data.commitMessage, author: data.author ?? "UNKNOWN", branch: data.branch)
        }
    }
    
   private static func acceptanceBody(with buildNumber: String, commitMessage: String, branch: String) -> String {
    return "{\n\"body\":{\"version\":1,\"type\":\"doc\",\"content\":[{\"type\":\"heading\",\"attrs\":{\"level\":3},\"content\":[{\"type\":\"text\",\"text\":\"Ready For Acceptance Build\"}]},{\"type\":\"table\",\"attrs\":{\"isNumberColumnEnabled\":false,\"layout\":\"default\"},\"content\":[{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Build number\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(buildNumber)\"}]}]}]},{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Commit message\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(commitMessage)\"}]}]}]},{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Branch\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(branch)\"}]}]}]}]},{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"This build was generated from code that has passed QA and has been merged\",\"marks\":[{\"type\":\"em\"}]}]}]}}"
    }
    
    private static func mergeRequestBody(with buildNumber: String, commitMessage: String, author: String, branch: String) -> String {
    return "{\n\"body\":{\"version\":1,\"type\":\"doc\",\"content\":[{\"type\":\"heading\",\"attrs\":{\"level\":3},\"content\":[{\"type\":\"text\",\"text\":\"Merge Request Build\"}]},{\"type\":\"table\",\"attrs\":{\"isNumberColumnEnabled\":false,\"layout\":\"default\"},\"content\":[{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Build number\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(buildNumber)\"}]}]}]},{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Commit message\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(commitMessage)\"}]}]}]},{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Branch\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(branch)\"}]}]}]},{\"type\":\"tableRow\",\"content\":[{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"Author\"}]}]},{\"type\":\"tableCell\",\"attrs\":{},\"content\":[{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"\(author)\"}]}]}]}]},{\"type\":\"paragraph\",\"content\":[{\"type\":\"text\",\"text\":\"This build was generated from a branch that has not passed QA\",\"marks\":[{\"type\":\"em\"}]}]},{\"type\":\"paragraph\",\"content\":[]}]}}"
    }
}
