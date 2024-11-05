//
//  MessageViewModel.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation
import FirebaseFirestore

class MessageViewModel: ObservableObject {
    @Published var messages: [Message] = []
    
    private let db = Firestore.firestore()
    
    // Функция для получения сообщений
    func fetchMessages(for chatId: String) {
        Firestore.firestore().collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false) // сортировка по времени
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                self.messages = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                } ?? []
                
                print("Fetched messages: \(self.messages)") // Лог для проверки результатов
            }
    }
    
    // Функция для отправки сообщения
    func sendMessage(_ message: Message) {
        do {
            try db.collection("chats").document(message.chatId)
                .collection("messages")
                .document(message.id)
                .setData(from: message)
        } catch {
            print("Error sending message: \(error)")
        }
    }
    
    // Функция для обновления статуса прочтения сообщения
    func markMessageAsRead(_ messageId: String, in chatId: String) {
        db.collection("chats").document(chatId)
            .collection("messages")
            .document(messageId)
            .updateData(["readStatus": true]) { error in
                if let error = error {
                    print("Error updating message read status: \(error)")
                } else {
                    // Обновляем локальный массив сообщений
                    if let index = self.messages.firstIndex(where: { $0.id == messageId }) {
                        self.messages[index].readStatus = true
                    }
                }
            }
    }
    
    // Функция для удаления сообщения
    func deleteMessage(_ messageId: String, in chatId: String) {
        db.collection("chats").document(chatId).collection("messages").document(messageId).delete { error in
            if let error = error {
                print("Error deleting message: \(error)")
            } else {
                // Обновляем локальный массив сообщений
                self.messages.removeAll { $0.id == messageId }
            }
        }
    }
}
