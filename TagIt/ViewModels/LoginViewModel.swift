//
//  LoginViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-08.
//

import FirebaseAuth
import Foundation

/**
 Manages the state and logic related to user authentication.

 This view model handles user input for email and password, validates the input,
 and communicates with the authentication service to log users in. It also manages
 loading and error states to provide feedback to the user interface.
 */
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties

    /// The user's email address input.
    @Published var email: String = ""

    /// The user's password input.
    @Published var password: String = ""

    /// An optional error message to display if login fails.
    @Published var errorMessage: String? = nil

    /// Indicates whether the user is successfully logged in.
    @Published var isLoggedIn: Bool = false

    /// Indicates whether a login operation is currently in progress.
    @Published var isLoading: Bool = false

    // MARK: - Public Methods

    /**
         Initiates the login process using the provided email and password.

         This method validates the user input, communicates with the authentication service,
         and updates the login state based on the result. It manages loading and error states
         to inform the user interface accordingly.
     */
    func login() {
        guard validate() else { return }

        errorMessage = nil
        isLoading = true

        AuthService.shared.loginUser(withEmail: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case let .success(userId):
                    print("Login successful with userId: \(userId)")
                    self?.isLoggedIn = true
                case let .failure(error):
                    self?.errorMessage = error.localizedDescription // Display the specific error message
                    print("Login failed with error: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - Private Methods

    /**
         Validates the user's input for email and password.

         This method checks that the email and password fields are not empty and that the email
         has a valid format. If validation fails, it sets an appropriate error message.

         - Returns: `true` if the input is valid, `false` otherwise.
     */
    private func validate() -> Bool {
        errorMessage = nil
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Please fill in all fields."
            return false
        }

        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email."
            return false
        }

        return true
    }
}
