//
//  PasswordRecoveryViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation

/**
 Manages the state related to password recovery.

 This view model handles user input for email addresses and coordinates with the authentication service
 to initiate password reset processes. It manages loading and error states to provide feedback to the user interface.
 */
class PasswordRecoveryViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The user's email address input for initiating password recovery.
    @Published var email: String = ""
}
