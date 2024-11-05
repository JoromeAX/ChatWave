//
//  User.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation

struct User: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    let email: String
}
