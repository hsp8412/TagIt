//
//  HomeView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct HomeView: View {
    @State private var user: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    let userService = UserService()
    
    var body: some View {
        VStack {
            if let user = user {
                Text("Welcome, \(user.displayName)")
            } else if isLoading {
                ProgressView()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
            }
        }
        .onAppear {
            // Fetch the authenticated user's profile when the view appears
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        // Listen for the auth state to get the current user's ID
        AuthService.shared.addAuthStateChangeListener { userId in
            if let userId = userId {
                userService.getUserById(id: userId) { result in
                    switch result {
                    case .success(let fetchedUser):
                        self.user = fetchedUser
                        self.isLoading = false
                    case .failure(let error):
                        self.errorMessage = "Failed to load user profile: \(error.localizedDescription)"
                        self.isLoading = false
                    }
                }
            } else {
                // Handle case where user is not logged in
                self.errorMessage = "User not logged in"
                self.isLoading = false
            }
        }
    }
}


#Preview {
    HomeView()
}
