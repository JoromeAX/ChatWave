//
//  Message.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String
    let chatId: String
    let senderId: String
    let senderName: String
    let text: String
    let timestamp: Date
    var readStatus: Bool
}
