//
//  Message.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    let id: String // Уникальный идентификатор сообщения
    let chatId: String // ID чата, к которому относится сообщение
    let senderId: String // ID пользователя, отправившего сообщение
    let senderName: String
    let text: String // Текст сообщения
    let timestamp: Date // Дата и время отправки сообщения
    var readStatus: Bool // Статус прочтения сообщения
}
