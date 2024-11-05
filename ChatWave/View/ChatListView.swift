//
//  ChatListView.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import SwiftUI
import FirebaseAuth

struct ChatListView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var messageViewModel: MessageViewModel
    @State private var showingNewChat = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(chatViewModel.chats) { chat in
                    NavigationLink(destination: ChatDetailView(chatId: chat.id, chatViewModel: chatViewModel, messageViewModel: messageViewModel, userViewModel: userViewModel, authViewModel: authViewModel)) {
                        HStack {
                            Text(chat.name)
                                .font(.headline)
                            Spacer()
                            if let lastMessage = chat.lastMessage {
                                Text(lastMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteChat)
            }
            .navigationTitle("Chats")
            .navigationBarItems(
                leading: Button(action: logOut) {
                    Text("Log Out")
                        .foregroundColor(.red)
                },
                trailing: Button(action: {
                    showingNewChat.toggle()
                }) {
                    Image(systemName: "plus")
                }
            )
            .sheet(isPresented: $showingNewChat) {
                NewChatView(userViewModel: userViewModel, chatViewModel: chatViewModel, authViewModel: authViewModel)
            }
            .onAppear {
                if let currentUserID = Auth.auth().currentUser?.uid {
                    print("Current user ID: \(currentUserID)")
                    chatViewModel.fetchChats(for: currentUserID)
                } else {
                    print("No user is currently signed in.")
                }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func logOut() {
        do {
            try Auth.auth().signOut()
            authViewModel.isLoggedIn = false
            print("Logged out successfully")
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    private func deleteChat(at offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let chatId = chatViewModel.chats[index].id
        chatViewModel.leaveChat(chatId: chatId, userViewModel: userViewModel, authViewModel: authViewModel, completion: nil)
    }
}
