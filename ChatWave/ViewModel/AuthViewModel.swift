//
//  AuthViewModel.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoggedIn = false // Отслеживает состояние авторизации
    private let db = Firestore.firestore()
    private var authListener: AuthStateDidChangeListenerHandle?
    
    init() {
        // Устанавливаем слушателя на изменения состояния аутентификации
        authListener = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            if let user = user {
                self?.isLoggedIn = true
                self?.fetchUserFromFirestore(userId: user.uid)
            } else {
                self?.isLoggedIn = false
                self?.user = nil
            }
        }
    }
    
    deinit {
        // Удаляем слушателя при уничтожении
        if let authListener = authListener {
            Auth.auth().removeStateDidChangeListener(authListener)
        }
    }
    
    func register(email: String, password: String, name: String, completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Error registering: \(error.localizedDescription)")
                return
            }
            guard let authUser = authResult?.user else { return }
            
            let newUser = User(id: authUser.uid, name: name, email: email)
            self?.user = newUser
            self?.saveUserToFirestore(user: newUser)
            self?.isLoggedIn = true // Устанавливаем состояние авторизации в true
            completion() // Уведомляем о завершении регистрации
        }
    }
    
    func login(email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                print("Error logging in: \(error.localizedDescription)")
                return
            }
            guard let authUser = authResult?.user else { return }
            self?.fetchUserFromFirestore(userId: authUser.uid)
            self?.isLoggedIn = true // Устанавливаем состояние авторизации в true
            completion() // Уведомляем о завершении входа
        }
    }
    
    private func saveUserToFirestore(user: User) {
        do {
            try db.collection("users").document(user.id).setData(from: user)
        } catch {
            print("Error saving user: \(error.localizedDescription)")
        }
    }
    
    func fetchUserFromFirestore(userId: String) {
        print("Fetching user with ID: \(userId)")
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            if let error = error {
                print("Error fetching user: \(error.localizedDescription)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist for ID: \(userId)")
                return
            }
            
            do {
                // Декодируем документ и присваиваем ID из Firestore
                var userData = try document.data(as: User.self)
                userData.id = document.documentID
                self?.user = userData
                print("User fetched successfully: \(userData)")
            } catch {
                print("Error decoding user data: \(error.localizedDescription)")
            }
        }
    }
}
