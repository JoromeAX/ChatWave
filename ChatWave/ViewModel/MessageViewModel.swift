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
    
    func fetchMessages(for chatId: String) {
        Firestore.firestore().collection("chats").document(chatId).collection("messages")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching messages: \(error)")
                    return
                }
                
                self.messages = snapshot?.documents.compactMap { doc in
                    try? doc.data(as: Message.self)
                } ?? []
                
                print("Fetched messages: \(self.messages)")
            }
    }
    
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
    
    func markMessageAsRead(_ messageId: String, in chatId: String) {
        db.collection("chats").document(chatId)
            .collection("messages")
            .document(messageId)
            .updateData(["readStatus": true]) { error in
                if let error = error {
                    print("Error updating message read status: \(error)")
                } else {
                    if let index = self.messages.firstIndex(where: { $0.id == messageId }) {
                        self.messages[index].readStatus = true
                    }
                }
            }
    }
    
    func deleteMessage(_ messageId: String, in chatId: String) {
        db.collection("chats").document(chatId).collection("messages").document(messageId).delete { error in
            if let error = error {
                print("Error deleting message: \(error)")
            } else {
                self.messages.removeAll { $0.id == messageId }
            }
        }
    }
}
