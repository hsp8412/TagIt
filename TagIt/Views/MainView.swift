//
//  MainView.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import SwiftUI

/**
 `MainView` serves as the entry point of the app. It checks whether the user is signed in and displays either the main content or the login view accordingly.

 - If the user is signed in, it displays the `ContentView` which contains the main navigation of the app.
 - If the user is not signed in, it displays the `LoginView` to allow the user to log in or register.
 */
struct MainView: View {
    @StateObject var viewModel = MainViewModel() // View model that handles user authentication state

    var body: some View {
        // Check if the user is signed in
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            // If signed in, show the main content view
            ContentView()
        } else {
            // If not signed in, show the login view
            LoginView()
        }
    }
}

#Preview {
    ContentView()
}
