//
//  Event.swift
//  Feeder
//
//  Created by Aritro Paul on 6/20/21.
//

import Foundation

struct Event: Codable {
    var id: String
    var type: String
    var actor: Actor
    var repo: Repo
    var repository: Repository?
    var created_at: String
}

struct Actor: Codable {
    var id: Int
    var login: String
    var display_login: String
    var avatar_url: String
    var url: String
}

struct Repo: Codable {
    var id: Int
    var name: String
    var url: String
    var isStarred: Bool? = false
}


