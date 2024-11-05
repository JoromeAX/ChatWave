//
//  LoginView.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var goToRegister = false // Для переключения на экран регистрации
    @State private var goToChatList = false // Для переключения на экран чатов
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var messageViewModel: MessageViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Login")) {
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    Button("Login") {
                        authViewModel.login(email: email, password: password) {
                            // Вызываем этот замыкание после успешного входа
                            goToChatList = true
                        }
                    }
                }

                // Кнопка для перехода на экран регистрации
                Button(action: {
                    goToRegister = true
                }) {
                    Text("Don't have an account? Register")
                        .foregroundColor(.blue)
                }
                .padding()
                .navigationDestination(isPresented: $goToRegister) {
                    RegisterView(authViewModel: authViewModel, chatViewModel: chatViewModel, userViewModel: userViewModel, messageViewModel: messageViewModel)
                }
                .navigationDestination(isPresented: $goToChatList) {
                    ChatListView(chatViewModel: chatViewModel, authViewModel: authViewModel, userViewModel: userViewModel, messageViewModel: messageViewModel)
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .scrollDisabled(true)
    }
}
