//
//  Repository.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import Foundation

struct Repository: Codable {
    var id: Int
    var full_name: String
    var url: String
    var stargazers_count: Int
    var description: String?
    var owner: Owner
    var language: String?
}

struct Owner: Codable {
    var login: String
    var avatar_url: String
    var html_url: String
}
