#!/usr/bin/env swift
import Foundation

if !(CommandLine.argc > 1) {
    print("No arguments, sorry. I'm out.")
    exit(1)
}

do {
    guard let commentType = JiraPost.CommentType(rawValue: CommandLine.arguments[1]) else {
        print("The argument passed did not match the two configuration options available; use either 'acceptance' or 'merge'")
        exit(1)
    }
    
    try JiraPost.post(with: commentType)
} catch {
    print("An unknown error occured: \(error)")
    exit(1)
}

