//
//  HomeView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-07.
//

import SwiftUI

struct HomeView: View {
    @StateObject var userService = UserService.shared // Reference the singleton instance
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let user = userService.userProfile {
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
        _ = AuthService.shared.addAuthStateChangeListener { userId in
            if let userId = userId {
                userService.loadUserProfile(userId: userId) // Load the profile via the singleton
                self.isLoading = false
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
