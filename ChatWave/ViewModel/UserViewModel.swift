//
//  UserViewModel.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var users: Set<User> = [] // Используем Set для уникальных пользователей
    @Published var searchText = ""
    
    private let db = Firestore.firestore()
    
    var authViewModel: AuthViewModel? // Ссылка на AuthViewModel
    
    var filteredUsers: [User] {
        let filtered = users.filter { user in
            // Исключаем текущего пользователя
            guard let currentUserID = authViewModel?.user?.id else { return true }
            return user.name.contains(searchText) && user.id != currentUserID
        }
        return Array(filtered)
    }
    
    func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error)")
                return
            }
            
            // Загружаем пользователей и добавляем в Set
            if let documents = snapshot?.documents {
                for document in documents {
                    if let user = try? document.data(as: User.self) {
                        self.users.insert(user) // Используем insert для добавления в Set
                    }
                }
            }
            print("Fetched users:", self.users.map { $0.name }) // Лог для проверки пользователей
        }
    }
}
