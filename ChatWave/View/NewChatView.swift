//
//  NewChatView.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import SwiftUI

struct NewChatView: View {
    @State private var chatName = ""
    @State private var selectedParticipants: [String] = []
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    @ObservedObject var authViewModel: AuthViewModel
    
    init(userViewModel: UserViewModel, chatViewModel: ChatViewModel, authViewModel: AuthViewModel) {
        self.userViewModel = userViewModel
        self.chatViewModel = chatViewModel
        self.authViewModel = authViewModel
        self.userViewModel.authViewModel = authViewModel
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Chat Name")) {
                    TextField("Enter chat name", text: $chatName)
                }
                
                Section(header: Text("Select Participants")) {
                    TextField("Search by name", text: $userViewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical, 5)
                    
                    List(userViewModel.filteredUsers) { user in
                        MultipleSelectionRow(title: user.name, isSelected: selectedParticipants.contains(user.id)) {
                            if selectedParticipants.contains(user.id) {
                                selectedParticipants.removeAll { $0 == user.id }
                            } else {
                                selectedParticipants.append(user.id)
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Chat")
            .navigationBarItems(trailing: Button("Create") {
                guard let currentUserID = authViewModel.user?.id else { return }
                
                let chatId = UUID().uuidString
                let participants = selectedParticipants + [currentUserID]
                
                let newChat = Chat(
                    id: chatId,
                    name: chatName,
                    participants: participants,
                    isGroup: participants.count > 2,
                    lastMessage: nil,
                    timestampLastMessage: nil,
                    deletedBy: []
                )
                
                chatViewModel.addChat(chat: newChat)
                presentationMode.wrappedValue.dismiss()
            })
        }
        .onAppear {
            userViewModel.fetchUsers()
        }
    }
}

struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
    }
}
