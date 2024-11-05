//
//  ChatDetailView.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import SwiftUI

struct ChatDetailView: View {
    let chatId: String
    @ObservedObject var chatViewModel: ChatViewModel
    @ObservedObject var messageViewModel: MessageViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @State private var newMessageText = ""
    @State private var showDeleteAlert = false
    @State private var selectedMessageId: String?
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            MessageListView(
                messageViewModel: messageViewModel,
                authViewModel: authViewModel,
                showDeleteAlert: $showDeleteAlert,
                selectedMessageId: $selectedMessageId
            )
            
            HStack {
                TextField("Type a message...", text: $newMessageText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                Button(action: sendMessage) {
                    Text("Send")
                }
                .padding()
                .disabled(newMessageText.isEmpty)
            }
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            trailing: Button("Delete chat for you") {
                chatViewModel.leaveChat(chatId: chatId, userViewModel: userViewModel, authViewModel: authViewModel) {
                    presentationMode.wrappedValue.dismiss()
                }
            }
                .foregroundStyle(.red)
        )
        .onAppear {
            messageViewModel.fetchMessages(for: chatId)
            userViewModel.fetchUsers()
        }
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Are you sure?"),
                message: Text("Do you really want to delete this message?"),
                primaryButton: .destructive(Text("Yes")) {
                    if let messageId = selectedMessageId {
                        messageViewModel.deleteMessage(messageId, in: chatId)
                    }
                },
                secondaryButton: .cancel(Text("No"))
            )
        }
    }
    
    private func sendMessage() {
        guard let user = authViewModel.user, !newMessageText.isEmpty else { return }
        let messageId = UUID().uuidString
        let message = Message(
            id: messageId,
            chatId: chatId,
            senderId: user.id,
            senderName: user.name,
            text: newMessageText,
            timestamp: Date(),
            readStatus: false
        )
        messageViewModel.sendMessage(message)
        newMessageText = ""
        markMessagesAsRead()
    }
    
    private func markMessagesAsRead() {
        for message in messageViewModel.messages where !message.readStatus {
            messageViewModel.markMessageAsRead(message.id, in: chatId)
        }
    }
}
