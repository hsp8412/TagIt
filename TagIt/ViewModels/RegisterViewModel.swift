//
//  RegisterViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation
import SwiftUI

/**
 Manages the state and logic related to user registration.

 This view model handles user input for email, password, and username, validates the input,
 and communicates with the authentication service to register new users. It also manages
 loading and error states to provide feedback to the user interface.
 */
class RegisterViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The user's email address input.
    @Published var email: String = ""

    /// The user's password input.
    @Published var password: String = ""

    /// The confirmation of the user's password input.
    @Published var confirmPassword: String = ""

    /// The user's chosen username.
    @Published var username: String = ""

    /// An optional error message to display if registration fails.
    @Published var errorMessage: String? = nil

    /// Indicates whether the user has successfully registered.
    @Published var isRegistered: Bool = false

    /// Indicates whether a registration operation is currently in progress.
    @Published var isLoading: Bool = false

    // MARK: - Public Methods

    /**
         Initiates the user registration process.

         This method validates the user input, communicates with the authentication service,
         and updates the registration state based on the result. It manages loading and error states
         to inform the user interface accordingly.
     */
    func register() {
        // Validate input
        guard validate() else { return }

        errorMessage = nil
        isLoading = true

        AuthService.shared.registerUser(withEmail: email, password: password, displayName: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case let .success(userId):
                    print("Registration successful with userId: \(userId)")
                    self?.isRegistered = true
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription
                    print("Registration failed with error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Private Methods

    /**
         Validates the user's input for registration.

         This method ensures that all required fields are filled, the email has a valid format,
         the password meets complexity requirements, and the password and confirmation match.
         If validation fails, it sets an appropriate error message.

         - Returns: `true` if the input is valid, `false` otherwise.
     */
    private func validate() -> Bool {
        errorMessage = nil

        // All fields are required
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            errorMessage = "Please fill in all fields."
            return false
        }

        // Check username length
        guard username.count > 3 else {
            errorMessage = "Username must be more than 3 characters."
            return false
        }

        // Check if email is valid
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email."
            return false
        }

        // Check if password meets complexity requirements
        guard isPasswordComplex(password) else {
            errorMessage = "Password must be at least 8 characters, with letters and numbers."
            return false
        }

        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }

        return true
    }

    /**
         Validates the format of the provided email address.

         - Parameter email: The email address to validate.

         - Returns: `true` if the email format is valid, `false` otherwise.
     */
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    /**
         Validates the complexity of the provided password.

         The password must be at least 8 characters long and contain both letters and numbers.

         - Parameter password: The password to validate.

         - Returns: `true` if the password meets complexity requirements, `false` otherwise.
     */
    private func isPasswordComplex(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
}
