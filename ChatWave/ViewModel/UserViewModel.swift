//
//  UserViewModel.swift
//  ChatWave
//
//  Created by Roman Khancha on 31.10.2024.
//

import Foundation
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var users: Set<User> = []
    @Published var searchText = ""
    
    private let db = Firestore.firestore()
    
    var authViewModel: AuthViewModel?
    
    var filteredUsers: [User] {
        let filtered = users.filter { user in
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
            
            if let documents = snapshot?.documents {
                for document in documents {
                    if let user = try? document.data(as: User.self) {
                        self.users.insert(user)
                    }
                }
            }
            print("Fetched users:", self.users.map { $0.name })
        }
    }
}
