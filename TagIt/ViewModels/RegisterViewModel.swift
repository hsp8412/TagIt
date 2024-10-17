//
//  RegisterViewModel.swift
//  TagIt
//
//  Created by 何斯鹏 on 2024-10-16.
//

import Foundation

import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var username: String = ""
    @Published var errorMessage: String? = nil
    @Published var isRegistered: Bool = false
    @Published var isLoading: Bool = false

    func register() {
        // Validate input
        guard validate() else { return }
        
        errorMessage = nil
        isLoading = true

        AuthService.shared.registerUser(withEmail: email, password: password, displayName: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let userId):
                    print("Registration successful with userId: \(userId)")
                    self?.isRegistered = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    print("Registration failed with error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Validation method to check all conditions
    private func validate() -> Bool {
        errorMessage = nil
        
        // all fields are required
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

    // Email validation using regex
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    // Password complexity validation
    private func isPasswordComplex(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
    
}

