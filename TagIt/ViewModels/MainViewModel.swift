//
//  MainViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import FirebaseAuth
import Foundation

/**
 Manages the authentication state of the user.

 This view model listens for changes in the user's authentication status,
 updates the current user ID, and provides a computed property to check
 if a user is signed in.
 */
class MainViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The unique identifier of the currently authenticated user.
    @Published var currentUserId: String = ""

    // MARK: - Private Properties

    /// The handle for the authentication state change listener.
    private var handler: AuthStateDidChangeListenerHandle?

    // MARK: - Initializer

    /**
         Initializes the `MainViewModel` and sets up a listener for authentication state changes.

         This initializer adds a listener to Firebase Authentication to monitor changes in the user's
         authentication status. When a change is detected, it updates the `currentUserId` accordingly.
     */
    init() {
        handler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUserId = user?.uid ?? ""
            }
        }
    }

    // MARK: - Computed Properties

    /**
         Indicates whether a user is currently signed in.

         - Returns: `true` if a user is signed in; otherwise, `false`.
     */
    public var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Deinitializer

    /**
         Removes the authentication state change listener when the view model is deallocated.
     */
    deinit {
        if let handler {
            Auth.auth().removeStateDidChangeListener(handler)
        }
    }
}
