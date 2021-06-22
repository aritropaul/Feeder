//
//  User.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import Foundation

struct User: Codable {
    var login: String
    var id: Int
    var avatar_url: String
    var name: String
    var email: String
    var bio: String
    var html_url: String
    var twitter_username: String?
}
