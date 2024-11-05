//
//  Chat.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: String
    let name: String
    let participants: [String]
    let isGroup: Bool
    var lastMessage: String?
    var timestampLastMessage: Date?
    var deletedBy: [String?]
}
