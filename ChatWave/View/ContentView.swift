//
//  ContentView.swift
//  ChatWave
//
//  Created by Roman Khancha on 01.11.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var authViewModel = AuthViewModel()
    @ObservedObject var chatViewModel = ChatViewModel()
    @ObservedObject var userViewModel = UserViewModel()
    @ObservedObject var messageViewModel = MessageViewModel()

    var body: some View {
        Group {
            if authViewModel.isLoggedIn {
                ChatListView(chatViewModel: chatViewModel, authViewModel: authViewModel, userViewModel: userViewModel, messageViewModel: messageViewModel)
            } else {
                LoginView(authViewModel: authViewModel, chatViewModel: chatViewModel, userViewModel: userViewModel, messageViewModel: messageViewModel)
            }
        }
    }
}
