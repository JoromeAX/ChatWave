//
//  Chat.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: String // Уникальный идентификатор чата
    let name: String // Название чата
    let participants: [String] // Список ID пользователей
    let isGroup: Bool // Указывает, является ли чат групповым
    var lastMessage: String? // Последнее сообщение (опционально)
    var timestampLastMessage: Date? // Дата и время последнего сообщения (опционально)
    var deletedBy: [String?]
}
