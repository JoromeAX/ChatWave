//
//  RegisterView.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import SwiftUI

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var goToLogin = false // Для переключения на экран входа
    @State private var goToChatList = false // Для переключения на экран чатов
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    @ObservedObject var userViewModel: UserViewModel
    @ObservedObject var messageViewModel: MessageViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    Section(header: Text("Register")) {
                        TextField("Name", text: $name)
                        TextField("Email", text: $email)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    Button("Register") {
                        authViewModel.register(email: email, password: password, name: name) {
                            // Вызываем этот замыкание после успешной регистрации
                            goToChatList = true
                        }
                    }
                }
                
                // Кнопка для перехода на экран входа
                Button(action: {
                    goToLogin = true
                }) {
                    Text("Already have an account? Login")
                        .foregroundColor(.blue)
                }
                .padding()
                .navigationDestination(isPresented: $goToLogin) {
                    LoginView(authViewModel: authViewModel, chatViewModel: chatViewModel, userViewModel: userViewModel, messageViewModel: messageViewModel)
                }
                .navigationDestination(isPresented: $goToChatList) {
                    ChatListView(chatViewModel: chatViewModel, authViewModel: authViewModel, userViewModel: userViewModel, messageViewModel: messageViewModel)
                }
            }
            .navigationTitle("Register")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
        }
        .scrollDisabled(true)
    }
}
