//
//  ChatViewModel.swift
//  ChatWave
//
//  Created by Roman Khancha on 26.10.2024.
//

import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var chats: [Chat] = []
    
    private let db = Firestore.firestore()
    
    func fetchChats(for userId: String) {
        db.collection("chats")
            .whereField("participants", arrayContains: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching chats: \(error)")
                    return
                }
                self.chats = snapshot?.documents.compactMap { doc in
                    let chat = try? doc.data(as: Chat.self)
                    
                    if let safeChat = chat, !(safeChat.deletedBy.contains { $0 == userId }) {
                        return safeChat
                    } else {
                        return nil
                    }
                } ?? []
                
                print("Fetched chats: \(self.chats)")
            }
    }
    
    func addChat(chat: Chat) {
        do {
            try db.collection("chats").document(chat.id).setData(from: chat)
        } catch {
            print("Error adding chat: \(error)")
        }
    }
    
    func leaveChat(chatId: String, userViewModel: UserViewModel, authViewModel: AuthViewModel, completion: (() -> Void)? = nil) {
        guard let userId = authViewModel.user?.id,
              let userName = userViewModel.users.first(where: { $0.id == userId })?.name else {
            print("User ID or name not found.")
            return
        }
        
        let chatRef = Firestore.firestore().collection("chats").document(chatId)
        
        chatRef.updateData([
            "deletedBy": FieldValue.arrayUnion([userId])
        ]) { error in
            if let error = error {
                print("Error leaving chat: \(error)")
                return
            }
            
            chatRef.getDocument { document, error in
                if let document = document, document.exists {
                    let data = document.data()
                    let deletedBy = data?["deletedBy"] as? [String] ?? []
                    let participants = data?["participants"] as? [String] ?? []
                    
                    let remainingParticipants = participants.count - deletedBy.count
                    
                    if remainingParticipants == 0 {
                        self.deleteChatAndMessages(chatId: chatId)
                    } else {
                        let exitMessageId = UUID().uuidString
                        let exitMessage = Message(
                            id: exitMessageId,
                            chatId: chatId,
                            senderId: userId,
                            senderName: userName,
                            text: "Left the chat",
                            timestamp: Date(),
                            readStatus: false
                        )
                        self.sendMessage(exitMessage)
                    }
                }
                
                completion?()
            }
        }
    }
    
    func sendMessage(_ message: Message) {
        let chatRef = Firestore.firestore().collection("chats").document(message.chatId)
        
        chatRef.collection("messages").document(message.id).setData([
            "id": message.id,
            "chatId": message.chatId,
            "senderId": message.senderId,
            "senderName": message.senderName,
            "text": message.text,
            "timestamp": message.timestamp,
            "readStatus": message.readStatus
        ]) { error in
            if let error = error {
                print("Error sending message: \(error)")
            } else {
                print("Message sent successfully.")
            }
        }
    }
    
    func deleteChatAndMessages(chatId: String) {
        let chatRef = Firestore.firestore().collection("chats").document(chatId)
        let messagesRef = chatRef.collection("messages")
        
        messagesRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching messages: \(error)")
                return
            }
            
            let batch = Firestore.firestore().batch()
            
            snapshot?.documents.forEach { document in
                batch.deleteDocument(document.reference)
            }
            
            batch.commit { error in
                if let error = error {
                    print("Error deleting messages: \(error)")
                    return
                }
                
                chatRef.delete { error in
                    if let error = error {
                        print("Error deleting chat: \(error)")
                    } else {
                        print("Chat and its messages deleted successfully.")
                    }
                }
            }
        }
    }
}
